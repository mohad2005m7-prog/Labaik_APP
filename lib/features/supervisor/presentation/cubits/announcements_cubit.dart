import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/api_error_text.dart';
import '../../../../core/l10n/tx.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/supervisor_repository.dart';
import '../l10n/announcements_text.dart';
import '../widgets/supervisor_format.dart';

// -------------------------------------------------------------
// الإعلانات:
//   AnnouncementsCubit — "إعلانات سابقة" (اللي أرسلها المشرف أول القائمة)
//   AnnouncementFormCubit — "إنشاء إعلان جديد": المسودة بتنحفظ على الجهاز أول بأول (حفظ التقدم)
//     والإرسال ما بيمشي بدون عنوان ونوع ونص
// -------------------------------------------------------------
class AnnouncementsState extends Equatable {
  final bool loaded;
  final List<Announcement> items;

  const AnnouncementsState({this.loaded = false, this.items = const []});

  @override
  List<Object?> get props => [loaded, items];
}

class AnnouncementsCubit extends Cubit<AnnouncementsState> {
  AnnouncementsCubit(this._repository) : super(const AnnouncementsState());

  final SupervisorRepository _repository;

  Future<void> load() async {
    try {
      final items = await _repository.getAnnouncements();
      if (!isClosed) emit(AnnouncementsState(loaded: true, items: items));
    } catch (_) {
      // ما في إنترنت أو السيرفر ما رد — بنضل على آخر قائمة
      if (!isClosed) emit(AnnouncementsState(loaded: true, items: state.items));
    }
  }

  /// بيوصل للسيرفر أول، وبعدين بيطلع أول القائمة — ولو فشل الخطأ بيرجع للفورم
  Future<void> send(Announcement announcement) async {
    final saved = await _repository.sendAnnouncement(announcement);
    if (!isClosed) emit(AnnouncementsState(loaded: true, items: [saved, ...state.items.where((a) => a.id != saved.id)]));
  }
}

// ---------------- إنشاء إعلان جديد ----------------
class AnnouncementFormState extends Equatable {
  final AnnouncementDraft draft;

  /// مفتاح ترجمة رسالة الخطأ (null = ما في) — [feedback] بيزيد مع كل رسالة/إرسال حتى الشاشة تتفاعل
  final Tx? message;
  final int feedback;

  /// زاد = انبعت إعلان (الشاشة بتنقل لـ "إعلانات سابقة")
  final int sent;

  const AnnouncementFormState({this.draft = AnnouncementDraft.empty, this.message, this.feedback = 0, this.sent = 0});

  AnnouncementFormState copyWith({AnnouncementDraft? draft, Tx? message, int? feedback, int? sent}) =>
      AnnouncementFormState(draft: draft ?? this.draft, message: message, feedback: feedback ?? this.feedback, sent: sent ?? this.sent);

  @override
  List<Object?> get props => [draft, message, feedback, sent];
}

class AnnouncementFormCubit extends Cubit<AnnouncementFormState> {
  AnnouncementFormCubit(this._repository, this._announcements) : super(const AnnouncementFormState());

  final SupervisorRepository _repository;
  final AnnouncementsCubit _announcements;
  Timer? _saveTimer;

  /// استرجاع المسودة المحفوظة (لو طلع من التطبيق وهو بيكتب)
  Future<void> restore() async {
    final draft = await _repository.loadDraft();
    if (!isClosed) emit(state.copyWith(draft: draft));
  }

  void setTitle(String v) => _update(state.draft.copyWith(title: v));
  void setBody(String v) => _update(state.draft.copyWith(body: v));
  void setType(AnnouncementType v) => _update(state.draft.copyWith(type: v));
  void setTarget(String v) => _update(state.draft.copyWith(target: v));
  void clearAttachment() => _update(state.draft.copyWith(clearAttachment: true));

  Future<void> setAttachment(String path) async {
    final stored = await _repository.storePhoto(path);
    if (!isClosed) _update(state.draft.copyWith(attachment: stored));
  }

  void _update(AnnouncementDraft draft) {
    emit(state.copyWith(draft: draft));
    // الحفظ بعد ما يوقف كتابة شوي (مش مع كل حرف)
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () => _repository.saveDraft(draft));
  }

  // الإرسال ماشي (أول طلب ممكن ياخد لحد دقيقة لو السيرفر نايم) — الضغطة التانية ما بتكرره
  bool _sending = false;

  /// [defaultTarget]: المجموعة الأساسية لو ما اختار "إرسال إلى"
  Future<void> submit({required String defaultTarget}) async {
    if (_sending) return;
    _sending = true;
    try {
      await _submit(defaultTarget);
    } finally {
      _sending = false;
    }
  }

  Future<void> _submit(String defaultTarget) async {
    final d = state.draft;
    final error = d.title.trim().isEmpty
        ? AnnouncementsText.errorTitle
        : d.type == null
            ? AnnouncementsText.errorType
            : d.body.trim().isEmpty
                ? AnnouncementsText.errorBody
                : null;
    if (error != null) {
      emit(state.copyWith(message: error, feedback: state.feedback + 1));
      return;
    }

    final now = DateTime.now();
    final target = d.target ?? defaultTarget;
    final body = d.body.trim();
    try {
      await _announcements.send(
        Announcement(
          id: 'new-${now.millisecondsSinceEpoch}',
          title: d.title.trim(),
          target: target,
          whenLabel: SupFormat.today(now),
          summary: body.split('\n').first,
          body: body,
          type: d.type!,
          icon: target == AnnouncementsText.allPilgrims() ? AnnouncementIcon.book : AnnouncementIcon.group,
          dateLabel: SupFormat.date(now),
          timeLabel: SupFormat.longTime(now),
          attachment: d.attachment,
        ),
      );
    } catch (error) {
      // ما وصل للسيرفر (إنترنت، أو مش مشرف المجموعة) — المسودة بتضل زي ما هي
      if (!isClosed) emit(state.copyWith(message: ApiErrorText.of(error), feedback: state.feedback + 1));
      return;
    }
    _saveTimer?.cancel();
    await _repository.saveDraft(AnnouncementDraft.empty);
    if (!isClosed) emit(AnnouncementFormState(message: AnnouncementsText.sent, feedback: state.feedback + 1, sent: state.sent + 1));
  }

  @override
  Future<void> close() {
    _saveTimer?.cancel();
    return super.close();
  }
}
