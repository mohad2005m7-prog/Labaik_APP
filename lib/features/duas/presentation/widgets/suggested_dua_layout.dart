// -------------------------------------------------------------
// أماكن كروت الأدعية المقترحة بإطارات Figma "1" … "10" (بنفس ترتيب نصوص SuggestedDuasSource)
// top/height = مستطيل الكرت (Group)
// textTop = أعلى سطر النص: محسوب من أعلى حبره الفعلي بـ Figma (absoluteRenderBounds) ناقص بُعد الحبر عن
//   أعلى السطر بنفس رسم التطبيق (بيختلف حسب التشكيل بأول سطر) — فالنص بيطلع بمكانه بـ Figma بالظبط
// textRight = طرف صندوق النص اليمين (Figma حاطط بعض النصوص أقرب لنص الكرت من غيرها)
// بعض الكروت بـ Figma بدون ظل أو أبعد بـ 1 من اليسار — منقولة زي ما هي
// -------------------------------------------------------------
class DuaCardLayout {
  final double top;
  final double height;
  final double textTop;
  final double textRight;
  final double left;
  final bool shadow;

  const DuaCardLayout({required this.top, required this.height, required this.textTop, required this.textRight, this.left = 16, this.shadow = true});

  static const width = 361.0;
  static const textWidth = 327.0;
}

const suggestedDuaLayouts = <List<DuaCardLayout>>[
  // 1 (174:3021)
  [
    DuaCardLayout(top: 125, height: 111, textTop: 134, textRight: 366), // 178:3856 — 4 سطر
    DuaCardLayout(top: 252, height: 90, textTop: 271.5, textRight: 366), // 397:3037 — النص جوّا المجموعة: مكانه من صورة الإطار
    DuaCardLayout(top: 358, height: 133, textTop: 366.9, textRight: 366), // 178:3882 — 5 سطر
    DuaCardLayout(top: 507, height: 121, textTop: 520.9, textRight: 366), // 178:3893 — 4 سطر
    DuaCardLayout(top: 644, height: 121, textTop: 657.9, textRight: 366), // 178:3904 — 3 سطر
  ],
  // 2 (178:3911)
  [
    DuaCardLayout(top: 125, height: 66, textTop: 151.8, textRight: 366), // 178:3951 — 1 سطر
    DuaCardLayout(top: 207, height: 73, textTop: 219.8, textRight: 366), // 178:3952 — 2 سطر
    DuaCardLayout(top: 296, height: 72, textTop: 307.8, textRight: 366), // 178:3953 — 2 سطر
    DuaCardLayout(top: 384, height: 79, textTop: 397.9, textRight: 366), // 178:3954 — 2 سطر
    DuaCardLayout(top: 479, height: 121, textTop: 482.9, textRight: 366), // 178:3955 — 5 سطر
    DuaCardLayout(top: 616, height: 98, textTop: 629.9, textRight: 366), // 178:3995 — 3 سطر
  ],
  // 3 (178:4018)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 131.3, textRight: 366), // 178:4062 — 3 سطر
    DuaCardLayout(top: 217, height: 73, textTop: 229.3, textRight: 366), // 178:4063 — 2 سطر
    DuaCardLayout(top: 306, height: 72, textTop: 322.9, textRight: 366), // 178:4064 — 2 سطر
    DuaCardLayout(top: 394, height: 79, textTop: 409.9, textRight: 366), // 178:4065 — 2 سطر
    DuaCardLayout(top: 489, height: 174, textTop: 492.9, textRight: 366), // 178:4066 — 7 سطر
    DuaCardLayout(top: 688, height: 84, textTop: 693.9, textRight: 354), // 178:4067 — 3 سطر
  ],
  // 4 (180:4127)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 131.3, textRight: 366), // 180:4171 — 3 سطر
    DuaCardLayout(top: 217, height: 73, textTop: 240.3, textRight: 366), // 180:4172 — 2 سطر
    DuaCardLayout(top: 306, height: 72, textTop: 322.9, textRight: 366), // 180:4173 — 1 سطر
    DuaCardLayout(top: 394, height: 95, textTop: 398.9, textRight: 366), // 180:4174 — 4 سطر
    DuaCardLayout(top: 505, height: 69, textTop: 517.9, textRight: 366), // 180:4175 — 2 سطر
    DuaCardLayout(top: 593, height: 84, textTop: 609.9, textRight: 354), // 180:4176 — 2 سطر
  ],
  // 5 (180:4220)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 131.8, textRight: 366), // 180:4264 — 3 سطر
    DuaCardLayout(top: 217, height: 73, textTop: 220.3, textRight: 366), // 180:4265 — 3 سطر
    DuaCardLayout(top: 306, height: 182, textTop: 308.9, textRight: 368), // 180:4266 — 8 سطر
    DuaCardLayout(top: 504, height: 69, textTop: 516.9, textRight: 366), // 180:4268 — 2 سطر
    DuaCardLayout(top: 592, height: 84, textTop: 608.9, textRight: 354), // 180:4269 — 2 سطر
  ],
  // 6 (180:4313)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 142.8, textRight: 366), // 180:4353 — 2 سطر
    DuaCardLayout(top: 217, height: 73, textTop: 242.8, textRight: 366), // 180:4354 — 1 سطر
    DuaCardLayout(top: 306, height: 88, textTop: 318.3, textRight: 366), // 180:4357 — 3 سطر
    DuaCardLayout(top: 410, height: 88, textTop: 422.9, textRight: 366, shadow: false), // 180:4399 — 3 سطر
    DuaCardLayout(top: 514, height: 69, textTop: 526.9, textRight: 366), // 180:4355 — 2 سطر
    DuaCardLayout(top: 602, height: 64, textTop: 607.9, textRight: 354), // 180:4356 — 2 سطر
    DuaCardLayout(top: 685, height: 64, textTop: 690.9, textRight: 354), // 180:4410 — 2 سطر
  ],
  // 7 (180:4417)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 131.8, textRight: 366), // 180:4465 — 3 سطر
    DuaCardLayout(top: 217, height: 91.7, textTop: 219.8, textRight: 366), // 180:4466 — 4 سطر
    DuaCardLayout(top: 325, height: 150, textTop: 332.2, textRight: 365), // 180:4470 — 6 سطر
    DuaCardLayout(top: 491, height: 142, textTop: 494.9, textRight: 366), // 180:4467 — 6 سطر
    DuaCardLayout(top: 652, height: 64, textTop: 657.9, textRight: 354), // 180:4469 — 2 سطر
  ],
  // 8 (180:4519)
  [
    DuaCardLayout(top: 125, height: 76, textTop: 140.3, textRight: 366), // 180:4559 — 2 سطر
    DuaCardLayout(top: 217, height: 91.7, textTop: 230.8, textRight: 366), // 180:4560 — 3 سطر
    DuaCardLayout(top: 325, height: 80, textTop: 346.3, textRight: 365), // 180:4563 — 2 سطر
    DuaCardLayout(top: 421, height: 94, textTop: 429.9, textRight: 366), // 180:4561 — 3 سطر
    DuaCardLayout(top: 534, height: 64, textTop: 539.9, textRight: 354), // 180:4562 — 2 سطر
    DuaCardLayout(top: 617, height: 71, textTop: 617.6, textRight: 353, left: 15), // 180:4616 — 3 سطر
  ],
  // 9 (180:4623)
  [
    DuaCardLayout(top: 125, height: 99, textTop: 131.3, textRight: 366), // 180:4667 — 4 سطر
    DuaCardLayout(top: 251, height: 65, textTop: 259.3, textRight: 366, shadow: false), // 180:4668 — 2 سطر
    DuaCardLayout(top: 332, height: 106, textTop: 340.9, textRight: 365), // 180:4672 — 4 سطر
    DuaCardLayout(top: 454, height: 94, textTop: 473.9, textRight: 366), // 180:4669 — 3 سطر
    DuaCardLayout(top: 564, height: 124, textTop: 571.9, textRight: 359), // 180:4670 — 5 سطر
  ],
  // 10 (180:4716)
  [
    DuaCardLayout(top: 125, height: 72, textTop: 138.8, textRight: 366), // 180:4756 — 2 سطر
    DuaCardLayout(top: 213, height: 93, textTop: 217.8, textRight: 366), // 180:4757 — 4 سطر
    DuaCardLayout(top: 322, height: 145, textTop: 328.9, textRight: 366), // 180:4760 — 6 سطر
    DuaCardLayout(top: 483, height: 85, textTop: 491.9, textRight: 359), // 180:4759 — 3 سطر
    DuaCardLayout(top: 592, height: 85, textTop: 611.9, textRight: 358, left: 15), // 180:4802 — 2 سطر
  ],
];
