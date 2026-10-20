import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/common_text.dart';
import '../../../../core/theme/figma_text.dart';
import '../../../../core/widgets/figma_line.dart';
import '../../../auth/data/models/trip_type.dart';
import '../../../pilgrim_account/presentation/controllers/pilgrim_account_controller.dart';
import '../../domain/entities/trip.dart';
import '../controllers/trip_details_controller.dart';
import '../cubits/trip_edit_cubit.dart';
import '../l10n/trip_about_text.dart';
import '../widgets/trip_choice_row.dart';
import '../widgets/trip_colors.dart';
import '../widgets/trip_edit_page.dart';
import '../widgets/trip_name_field.dart';
import '../widgets/trip_question.dart';

// -------------------------------------------------------------
// 10تعديل تفاصيل الرحلة — Figma (1:8086): "أخبرنا اكثر عن رحلتك؟" — الاسم — أول عمرة؟ — مع من ستسافر؟ (أكتر من خيار)
// → التالي: بتنحفظ الرحلة وبتطلع "تمت إضافة التفاصيل بنجاح!"
// الاسم أول مرة من حساب المعتمر (لو ما كتبه قبل هون)
// -------------------------------------------------------------
class EditAboutTripScreen extends StatefulWidget {
  const EditAboutTripScreen({super.key});

  @override
  State<EditAboutTripScreen> createState() => _EditAboutTripScreenState();
}

class _EditAboutTripScreenState extends State<EditAboutTripScreen> {
  late final _name = TextEditingController(text: _cubit.state.travelerName ?? '');

  TripEditCubit get _cubit => context.read<TripEditCubit>();

  // أماكن العلامات وأطراف الأسماء (مقاسة من رندر Figma)
  static const _companions = [
    (TravelCompanion.alone, 525.25, 342.0),
    (TravelCompanion.family, 556.75, 339.5),
    (TravelCompanion.group, 586.25, 339.5),
  ];

  @override
  void initState() {
    super.initState();
    if (_name.text.isEmpty) _fillAccountName();
  }

  Future<void> _fillAccountName() async {
    final name = await PilgrimAccountController.savedName();
    if (!mounted || name == null || name.isEmpty || _name.text.isNotEmpty) return;
    _name.text = name;
    _cubit.setTravelerName(name);
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  static String _companionLabel(TravelCompanion companion) => switch (companion) {
        TravelCompanion.alone => TripAboutText.alone(),
        TravelCompanion.family => TripAboutText.family(),
        TravelCompanion.group => TripAboutText.group(),
      };

  void _next() {
    FocusScope.of(context).unfocus();
    final trip = _cubit.state;
    if ((trip.travelerName ?? '').isEmpty || trip.firstTime == null || trip.companions.isEmpty) {
      TripDetailsController.showMessage(ScaffoldMessenger.of(context), TripAboutText.answerAll());
      return;
    }
    TripDetailsController.finish(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TripEditCubit, Trip>(
      builder: (context, trip) {
        final hajj = trip.type == TripType.hajj;
        return TripEditPage(
          steps: 7,
          button: CommonText.next(),
          onNext: _next,
          content: (c) {
            // الأسئلة SemiBold 16 والأجوبة 14 (بدون letter spacing) — #1F3B2E
            TextStyle answer() => c.style(14, 450, TripColors.green, lineHeight: null, letterSpacing: 0);
            final question = c.style(16, FigmaWeight.semiBold, TripColors.green);
            return [
              TripQuestion.title(c, TripAboutText.title(), top: 232, end: 376.5),
              c.line(TripAboutText.enterName(), left: 175.5, top: 274, width: 200, height: 22, style: c.style(16, 450, TripColors.green)),
              Positioned.fill(child: TripNameField(c: c, controller: _name, hint: TripAboutText.namePlaceholder(), onChanged: _cubit.setTravelerName)),
              c.line(TripAboutText.firstQuestion(hajj), left: 126, top: 363, width: 250, height: 22, style: question),
              Positioned.fill(
                child: TripChoiceRow(c: c, markLeft: 356.75, markTop: 400, round: true, checked: trip.firstTime == true, label: TripAboutText.firstYes(hajj), labelRight: 344, style: answer(), onTap: () => _cubit.setFirstTime(true)),
              ),
              Positioned.fill(
                child: TripChoiceRow(c: c, markLeft: 357.5, markTop: 433.25, round: true, checked: trip.firstTime == false, label: TripAboutText.firstNo(hajj), labelRight: 345.5, style: answer(), onTap: () => _cubit.setFirstTime(false)),
              ),
              c.line(TripAboutText.companionsQuestion(), left: 122, top: 473, width: 250, height: 22, style: question),
              c.text(TripAboutText.companionsHint(), left: 122.5, top: 501, width: 250, height: 16, dy: 0, style: c.style(12.5, 450, TripColors.green, lineHeight: null, letterSpacing: 0)),
              for (final (companion, top, labelRight) in _companions)
                Positioned.fill(
                  child: TripChoiceRow(
                    c: c,
                    markLeft: 352.75,
                    markTop: top,
                    round: false,
                    checked: trip.companions.contains(companion),
                    label: _companionLabel(companion),
                    labelRight: labelRight,
                    style: answer(),
                    onTap: () => _cubit.toggleCompanion(companion),
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
