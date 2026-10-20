import 'package:flutter/material.dart';

import '../../../../core/utils/figma_canvas.dart';
import '../../../auth/data/models/stay_type.dart';
import '../../../auth/presentation/l10n/stay_text.dart';
import 'trip_choice_row.dart';
import 'trip_colors.dart';
import 'trip_stay_chip.dart';

// -------------------------------------------------------------
// مدينة بشاشة "أين ستقيم؟" (Figma 8تعديل): "إقامتك في …" — ◯ فندق — ◯ مكان اخر — ☐ لم أحدد مكان إقامتي بعد
// Figma راسم مدينتين وأماكن عناصرهم مش متطابقة بالظبط، فكل مدينة بتاخد أرقام مدينتها بـ Figma
// (التالتة وبعدها بأرقام التانية)
// -------------------------------------------------------------
class StayBlockLayout {
  /// مكان كل علامة من أعلى "إقامتك في …"
  final double hotelTop;
  final double otherTop;
  final double undecidedTop;
  final double radioLeft;
  final double checkboxLeft;

  /// أطراف الأسماء
  final double hotelRight;
  final double otherRight;
  final double undecidedRight;

  const StayBlockLayout({
    required this.hotelTop,
    required this.otherTop,
    required this.undecidedTop,
    required this.radioLeft,
    required this.checkboxLeft,
    required this.hotelRight,
    required this.otherRight,
    required this.undecidedRight,
  });

  // مقاسة من رندر Figma (المدينة المنورة ثم مكة المكرمة)
  static const first = StayBlockLayout(hotelTop: 39.75, otherTop: 67.5, undecidedTop: 98.75, radioLeft: 351, checkboxLeft: 354.75, hotelRight: 343, otherRight: 339.5, undecidedRight: 346.5);
  static const next = StayBlockLayout(hotelTop: 43.75, otherTop: 71.25, undecidedTop: 101.75, radioLeft: 352.75, checkboxLeft: 352.75, hotelRight: 344, otherRight: 342.5, undecidedRight: 344);

  /// من أعلى "إقامتك في …" لأعلى اللي بعدها
  static const pitch = 135.0;
}

class TripStayTypeBlock extends StatelessWidget {
  final FigmaCanvas c;
  final double top;
  final StayBlockLayout layout;
  final String city;
  final StayType? type;
  final bool undecided;
  final ValueChanged<StayType> onType;
  final ValueChanged<bool> onUndecided;

  const TripStayTypeBlock({
    super.key,
    required this.c,
    required this.top,
    required this.layout,
    required this.city,
    required this.type,
    required this.undecided,
    required this.onType,
    required this.onUndecided,
  });

  @override
  Widget build(BuildContext context) {
    final l = layout;
    // SF Compact 12 (بدون letter spacing) — "فندق" بـ Figma لونه #4C7A75 و"لم أحدد…" أسود
    TextStyle label(Color color) => c.style(12, 450, color, lineHeight: null, letterSpacing: 0);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TripStayChip(c: c, left: 215, top: top, city: city),
        TripChoiceRow(
          c: c,
          markLeft: l.radioLeft,
          markTop: top + l.hotelTop,
          round: true,
          checked: type == StayType.hotel,
          label: StayText.hotel(),
          labelRight: l.hotelRight,
          style: label(TripColors.teal),
          labelDy: -2.5,
          onTap: () => onType(StayType.hotel),
        ),
        TripChoiceRow(
          c: c,
          markLeft: l.radioLeft,
          markTop: top + l.otherTop,
          round: true,
          checked: type == StayType.other,
          label: StayText.otherPlace(),
          labelRight: l.otherRight,
          style: label(TripColors.green),
          labelDy: -2.5,
          onTap: () => onType(StayType.other),
        ),
        TripChoiceRow(
          c: c,
          markLeft: l.checkboxLeft,
          markTop: top + l.undecidedTop,
          round: false,
          checked: undecided,
          label: StayText.notDecided(),
          labelRight: l.undecidedRight,
          style: label(Colors.black),
          labelDy: -2.5,
          onTap: () => onUndecided(!undecided),
        ),
      ],
    );
  }
}
