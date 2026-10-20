import 'package:equatable/equatable.dart';

// -------------------------------------------------------------
// دعاء مقترح ("أدعية مقترحة" → الدعاء الأول … العاشر): كل واحد كذا كرت نصوص
// النصوص عربية باللغتين (أدعية وآيات بتنقرأ بالعربي)
// -------------------------------------------------------------
class SuggestedDua extends Equatable {
  /// 1 … 10 (ترتيبه بالقائمة)
  final int number;
  final List<String> texts;

  const SuggestedDua({required this.number, required this.texts});

  @override
  List<Object> get props => [number, texts];
}
