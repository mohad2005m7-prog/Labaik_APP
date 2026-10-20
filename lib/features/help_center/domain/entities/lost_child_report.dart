import 'package:equatable/equatable.dart';

import '../../../../core/utils/geo_utils.dart';

// -------------------------------------------------------------
// بلاغ طفل مفقود (نموذج الإبلاغ): العمر التقريبي، وصفه وملابسه، الموقع الحالي، وصورة اختيارية
// -------------------------------------------------------------
class LostChildReport extends Equatable {
  /// العمر بالسنين (null = لسا ما اختار)
  final int? age;
  final String description;
  final GeoPoint? location;

  /// مسار الصورة على الجهاز (اختياري)
  final String? photoPath;

  const LostChildReport({this.age, this.description = '', this.location, this.photoPath});

  static const empty = LostChildReport();

  LostChildReport copyWith({int? age, String? description, GeoPoint? location, String? photoPath, bool removePhoto = false}) =>
      LostChildReport(age: age ?? this.age, description: description ?? this.description, location: location ?? this.location, photoPath: removePhoto ? null : photoPath ?? this.photoPath);

  @override
  List<Object?> get props => [age, description, location?.latitude, location?.longitude, photoPath];
}
