// نوع مكان الإقامة (فندق / مكان آخر)
enum StayType { hotel, other }

extension StayTypeLabel on StayType {
  String get arabicLabel {
    switch (this) {
      case StayType.hotel:
        return 'فندق';
      case StayType.other:
        return 'مكان اخر';
    }
  }
}
