import '../models/airport_model.dart';

// -------------------------------------------------------------
// قائمة مطارات السعودية (ثابتة مؤقتاً لحين ربطها بالـ API)
// مقسّمة لمجموعتين حسب التصنيف، وتُعرض بالقائمة المنسدلة.
//
// ملاحظة للمستقبل: عند إضافة مطارات دول أخرى، نعمل ملف مماثل لكل
// دولة (مثلاً egypt_airports.dart) بنفس هذا الشكل، ثم نجمعهم في
// خريطة واحدة حسب الدولة عند الحاجة.
// -------------------------------------------------------------
class SaudiAirports {
  // المطارات الدولية الرئيسية
  static const List<Airport> international = [
    Airport(code: 'RUH', name: 'مطار الملك خالد الدولي (RUH) - الرياض'),
    Airport(code: 'JED', name: 'مطار الملك عبد العزيز الدولي (JED) - جدة'),
    Airport(code: 'DMM', name: 'مطار الملك فهد الدولي (DMM) - الدمام'),
    Airport(code: 'MED', name: 'مطار الأمير محمد بن عبد العزيز الدولي (MED) - المدينة المنورة'),
    Airport(code: 'AHB', name: 'مطار أبها الدولي (AHB) - أبها'),
    Airport(code: 'ELQ', name: 'مطار الأمير نايف بن عبد العزيز الدولي (ELQ) - القصيم / بريدة'),
    Airport(code: 'TIF', name: 'مطار الطائف الدولي (TIF) - الطائف'),
    Airport(code: 'HAS', name: 'مطار حائل الدولي (HAS) - حائل'),
    Airport(code: 'ULH', name: 'مطار العلا الدولي (ULH) - العلا'),
    Airport(code: 'TUU', name: 'مطار الأمير سلطان بن عبد العزيز الدولي (TUU) - تبوك'),
    Airport(code: 'NUM', name: 'مطار خليج نيوم الدولي (NUM) - نيوم'),
    Airport(code: 'AJF', name: 'مطار الجوف الدولي (AJF) - الجوف'),
  ];

  // المطارات الإقليمية والمحلية والداخلية
  static const List<Airport> regional = [
    Airport(code: 'ABT', name: 'مطار الملك سعود المحلي (ABT) - الباحة'),
    Airport(code: 'HOF', name: 'مطار الأحساء الدولي (HOF) - الأحساء'),
    Airport(code: 'AQI', name: 'مطار القيصومة / حفر الباطن (AQI) - حفر الباطن'),
    Airport(code: 'GIZ', name: 'مطار جازان - الملك عبد الله الإقليمي (GIZ) - جازان'),
    Airport(code: 'EAM', name: 'مطار نجران (EAM) - نجران'),
    Airport(code: 'YNB', name: 'مطار ينبع - الأمير عبد المحسن بن عبد العزيز (YNB) - ينبع'),
    Airport(code: 'EJH', name: 'مطار الوجه المحلي (EJH) - الوجه'),
    Airport(code: 'RAE', name: 'مطار عرعر المحلي (RAE) - عرعر'),
    Airport(code: 'BHH', name: 'مطار بيشة المحلي (BHH) - بيشة'),
    Airport(code: 'URY', name: 'مطار القريات المحلي (URY) - القريات'),
    Airport(code: 'SHW', name: 'مطار شرورة المحلي (SHW) - شرورة'),
    Airport(code: 'RAH', name: 'مطار رفحاء المحلي (RAH) - رفحاء'),
  ];
}
