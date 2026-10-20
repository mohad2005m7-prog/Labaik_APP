import 'package:equatable/equatable.dart';

import '../../../auth/data/models/arrival_method_enum.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/data/models/trip_type.dart';

/// مع مين مسافر المعتمر ("مع من ستسافر؟" — بيقدر يختار أكتر من خيار)
enum TravelCompanion { alone, family, group }

// -------------------------------------------------------------
// رحلة المعتمر زي ما دخّلها بإعداد الحساب (وبيعدّلها من "تفاصيل الرحلة"):
// نوع الرحلة، وسيلة الوصول ومكانه، مسار المدن، موعد الوصول لمكة، الإقامة بكل مدينة،
// واسمه وإذا أول عمرة/حجة إله ومع مين مسافر
// -------------------------------------------------------------
class Trip extends Equatable {
  final TripType? type;
  final ArrivalMethod? arrivalMethod;

  /// رمز المطار (طائرة) أو اسم المنفذ / نقطة الوصول
  final String? arrivalPlace;
  final List<String> routeCities;

  /// موعد الوصول لمكة: التاريخ والوقت (دقائق من نص الليل)
  final DateTime? departureDate;
  final int? departureMinute;
  final bool departureNotDecided;

  /// نوع الإقامة بكل مدينة (فندق / مكان اخر) واسم الفندق أو المكان
  final Map<String, StayType> stayTypes;
  final Map<String, String> stayPlaces;

  /// المدن اللي اختار فيها "لم أحدد مكان إقامتي بعد"
  final List<String> stayUndecided;

  final String? travelerName;

  /// أول عمرة (أو حجة) إله؟
  final bool? firstTime;
  final Set<TravelCompanion> companions;

  const Trip({
    this.type,
    this.arrivalMethod,
    this.arrivalPlace,
    this.routeCities = const [],
    this.departureDate,
    this.departureMinute,
    this.departureNotDecided = false,
    this.stayTypes = const {},
    this.stayPlaces = const {},
    this.stayUndecided = const [],
    this.travelerName,
    this.firstTime,
    this.companions = const {},
  });

  static const empty = Trip();

  /// مدن الإقامة: مدن المسار، ولو ما اختار مدن المدينة المنورة ومكة المكرمة (زي إعداد الرحلة و Figma)
  List<String> get stayCities => routeCities.isEmpty ? const ['المدينة المنورة', 'مكة المكرمة'] : routeCities;

  Trip copyWith({
    TripType? type,
    ArrivalMethod? arrivalMethod,
    String? Function()? arrivalPlace,
    List<String>? routeCities,
    DateTime? Function()? departureDate,
    int? Function()? departureMinute,
    bool? departureNotDecided,
    Map<String, StayType>? stayTypes,
    Map<String, String>? stayPlaces,
    List<String>? stayUndecided,
    String? travelerName,
    bool? firstTime,
    Set<TravelCompanion>? companions,
  }) {
    return Trip(
      type: type ?? this.type,
      arrivalMethod: arrivalMethod ?? this.arrivalMethod,
      arrivalPlace: arrivalPlace == null ? this.arrivalPlace : arrivalPlace(),
      routeCities: routeCities ?? this.routeCities,
      departureDate: departureDate == null ? this.departureDate : departureDate(),
      departureMinute: departureMinute == null ? this.departureMinute : departureMinute(),
      departureNotDecided: departureNotDecided ?? this.departureNotDecided,
      stayTypes: stayTypes ?? this.stayTypes,
      stayPlaces: stayPlaces ?? this.stayPlaces,
      stayUndecided: stayUndecided ?? this.stayUndecided,
      travelerName: travelerName ?? this.travelerName,
      firstTime: firstTime ?? this.firstTime,
      companions: companions ?? this.companions,
    );
  }

  @override
  List<Object?> get props => [
        type,
        arrivalMethod,
        arrivalPlace,
        routeCities,
        departureDate,
        departureMinute,
        departureNotDecided,
        stayTypes,
        stayPlaces,
        stayUndecided,
        travelerName,
        firstTime,
        companions,
      ];
}
