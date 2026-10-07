// نوع الرحلة التي يقوم بها المستخدم
enum TripType { umrah, hajj }

extension TripTypeLabel on TripType {
  String get arabicLabel {
    switch (this) {
      case TripType.umrah:
        return 'عمرة';
      case TripType.hajj:
        return 'حج';
    }
  }
}
