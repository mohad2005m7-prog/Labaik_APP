import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/family_circle.dart';
import '../../domain/repositories/family_repository.dart';

enum FamilySetupTab { create, join }

class FamilySetupState extends Equatable {
  final FamilySetupTab tab;

  /// دائرتي (لـ "إنشاء دائرة العائلة": رمزها و QR تبعها)
  final FamilyCircle? circle;
  final bool creating;
  final Object? createError;

  /// جاري البحث بالرمز
  final bool lookingUp;

  const FamilySetupState({this.tab = FamilySetupTab.create, this.circle, this.creating = false, this.createError, this.lookingUp = false});

  FamilySetupState copyWith({FamilySetupTab? tab, FamilyCircle? circle, bool? creating, Object? createError, bool clearError = false, bool? lookingUp}) => FamilySetupState(
        tab: tab ?? this.tab,
        circle: circle ?? this.circle,
        creating: creating ?? this.creating,
        createError: clearError ? null : createError ?? this.createError,
        lookingUp: lookingUp ?? this.lookingUp,
      );

  @override
  List<Object?> get props => [tab, circle, creating, createError, lookingUp];
}

// -------------------------------------------------------------
// "إنشاء دائرة العائلة" / "إنضم إلى دائرة العائلة":
// الإنشاء بيصير أول ما يفتح تبويبه (السيرفر بيرجّع دائرتي لو موجودة — ما بتتكرر)
// الانضمام: البحث بالرمز المكتوب أو الممسوح من QR
// -------------------------------------------------------------
class FamilySetupCubit extends Cubit<FamilySetupState> {
  final FamilyRepository _repository;

  /// كل قديش بنشيّك إذا انضم حدا لدائرتي (وشاشة الإنشاء مفتوحة)
  final Duration watchInterval;

  FamilySetupCubit(this._repository, {FamilySetupTab tab = FamilySetupTab.create, FamilyCircle? circle, this.watchInterval = const Duration(seconds: 10)})
      : super(FamilySetupState(tab: tab, circle: circle));

  Timer? _watch;

  void start() {
    if (state.tab == FamilySetupTab.create) ensureCircle();
    _watch ??= Timer.periodic(watchInterval, (_) => _checkJoined());
  }

  /// دائرتي من السيرفر (عدد أفرادها) — لما ينضم أول فرد الشاشة بتكمل لحالها
  Future<void> _checkJoined() async {
    if (isClosed || state.tab != FamilySetupTab.create || state.circle == null || state.creating) return;
    try {
      final circle = await _repository.myCircle();
      if (!isClosed && circle != null) emit(state.copyWith(circle: circle));
    } catch (_) {
      // بنرجع نشيّك بعد شوي
    }
  }

  @override
  Future<void> close() {
    _watch?.cancel();
    return super.close();
  }

  void select(FamilySetupTab tab) {
    if (tab == state.tab) return;
    emit(state.copyWith(tab: tab));
    if (tab == FamilySetupTab.create) ensureCircle();
  }

  Future<void> ensureCircle() async {
    if (state.circle != null || state.creating) return;
    emit(state.copyWith(creating: true, clearError: true));
    try {
      final circle = await _repository.createCircle();
      if (!isClosed) emit(state.copyWith(circle: circle, creating: false));
    } catch (error) {
      if (!isClosed) emit(state.copyWith(creating: false, createError: error));
    }
  }

  /// null = ما في دائرة بهالرمز — ApiException لو فشل الطلب
  Future<FamilyCircleSummary?> find(String code) async {
    if (state.lookingUp) return null;
    emit(state.copyWith(lookingUp: true));
    try {
      return await _repository.findCircle(code);
    } finally {
      if (!isClosed) emit(state.copyWith(lookingUp: false));
    }
  }
}
