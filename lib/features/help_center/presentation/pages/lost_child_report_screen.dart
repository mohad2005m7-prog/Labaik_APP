import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/figma_text.dart';
import '../../../../core/utils/content_direction.dart';
import '../../../../core/utils/figma_canvas.dart';
import '../../../../core/widgets/figma_page.dart';
import '../../../trip_details/presentation/widgets/chevron_down_icon.dart';
import '../controllers/help_center_controller.dart';
import '../controllers/help_location.dart';
import '../cubits/lost_child_report_cubit.dart';
import '../l10n/lost_child_text.dart';
import '../widgets/age_picker_sheet.dart';
import '../widgets/help_colors.dart';
import '../widgets/help_text.dart';
import '../widgets/report_field.dart';
import '../widgets/report_photo_picker.dart';

// -------------------------------------------------------------
// "نموذج الإبلاغ عن طفل مفقود" (Figma 111:6002) — كل الأرقام من Figma:
// العمر التقريبي (قائمة) / وصف الطفل وملابسه (كتابة) / الموقع الحالي الفعلي (GPS) / صورة اختيارية (كاميرا أو صور)
// عنوان "وصف الطفل وملابسه" التاني (فوق حقل الموقع) انشال بطلب صاحب المشروع
// "إرسال البلاغ للمشرف" → هل ترغب بمشاركة البلاغ؟ (لازم العمر والوصف والموقع)
// -------------------------------------------------------------
class LostChildReportScreen extends StatefulWidget {
  const LostChildReportScreen({super.key});

  @override
  State<LostChildReportScreen> createState() => _LostChildReportScreenState();
}

class _LostChildReportScreenState extends State<LostChildReportScreen> {
  final _description = TextEditingController();
  final _descriptionFocus = FocusNode();

  LostChildReportCubit get _cubit => context.read<LostChildReportCubit>();

  @override
  void dispose() {
    _description.dispose();
    _descriptionFocus.dispose();
    super.dispose();
  }

  Future<void> _pickAge() async {
    FocusScope.of(context).unfocus();
    final years = await showAgePicker(context, selected: _cubit.state.report.age);
    if (years != null && mounted) _cubit.setAge(years);
  }

  Future<void> _attachLocation() async {
    if (_cubit.state.locating) return;
    FocusScope.of(context).unfocus();
    _cubit.setLocating(true);
    final point = await HelpLocation.current(context);
    if (!mounted) return;
    if (point == null) {
      _cubit.setLocating(false);
    } else {
      _cubit.setLocation(point);
    }
  }

  Future<void> _pickPhoto() async {
    FocusScope.of(context).unfocus();
    final choice = await ReportPhotoPicker.pick(context, hasPhoto: _cubit.state.report.photoPath != null);
    if (!mounted) return;
    switch (choice) {
      case ReportPhotoPicked(:final path):
        _cubit.setPhoto(path);
      case ReportPhotoRemoved():
        _cubit.removePhoto();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FigmaPage(
      title: LostChildText.title(),
      titleRight: 349,
      chevronLeft: 367,
      body: (c) {
        TextStyle label() => c.style(14, FigmaWeight.semiBold, Colors.black);
        return [
          HelpText.paragraph(c, LostChildText.description(), left: 16, top: 115, width: 361, lines: 2, style: c.style(14, FigmaWeight.semiBold, Colors.black)),
          HelpText.line(c, LostChildText.ageLabel(), right: 377, top: 172, boxWidth: 113, room: 361, style: label()),
          HelpText.line(c, LostChildText.descriptionLabel(), right: 378, top: 271, boxWidth: 121, room: 361, style: label()),
          HelpText.line(c, LostChildText.photoLabel(), right: 377.5, top: 518, boxWidth: 120.5, room: 361, style: label()),
          Positioned.fill(
            child: BlocBuilder<LostChildReportCubit, LostChildFormState>(
              builder: (context, state) => Stack(clipBehavior: Clip.none, children: _fields(c, state)),
            ),
          ),
          HelpText.paragraph(c, LostChildText.note(), left: 17, top: 644, width: 358, lines: 2, align: TextAlign.center, style: c.style(14, FigmaWeight.poppinsMedium, Colors.black)),
          c.button(LostChildText.send(), left: 17, top: 714, figmaSpacing: true, onTap: () => HelpCenterController.reviewReport(context)),
        ];
      },
    );
  }

  List<Widget> _fields(FigmaCanvas c, LostChildFormState state) {
    final report = state.report;
    final photo = report.photoPath;
    return [
      // العمر التقريبي للطفل ("Hicon / Linear / Down 3" يسار الحقل)
      ...ReportField.build(
        c,
        box: const Rect.fromLTWH(16, 202, 361, 53),
        text: report.age == null ? LostChildText.ageHint() : LostChildText.age(report.age!),
        empty: report.age == null,
        textRight: 360,
        textTop: 218,
        hintWidth: 86,
        room: 300,
        onTap: _pickAge,
        leading: [
          c.rect(
            left: 40,
            top: 226,
            width: 10,
            height: 4.3,
            child: IgnorePointer(
              child: Center(
                child: ChevronDownIcon(width: c.s.x(10), height: c.s.x(4.3), stroke: c.s.x(1.5), color: HelpColors.green),
              ),
            ),
          ),
        ],
      ),

      // وصف الطفل وملابسه (كتابة بعدة سطور)
      ReportField.frame(c, const Rect.fromLTWH(17, 301, 361, 102)),
      c.rect(
        left: 33,
        top: 315,
        width: 328,
        height: 80,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _description,
          builder: (context, value, _) {
            final style = c.style(14, FigmaWeight.sfRegular, Colors.black);
            return TextField(
              controller: _description,
              focusNode: _descriptionFocus,
              textDirection: contentDirection(value.text),
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              style: style,
              cursorColor: HelpColors.green,
              onChanged: _cubit.setDescription,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hint: Padding(
                  padding: EdgeInsets.only(top: c.s.y(FigmaCanvas.baselineFix)),
                  child: Align(
                    alignment: AlignmentDirectional.topStart,
                    child: HelpHint(
                      text: LostChildText.descriptionHint(),
                      width: c.s.x(268),
                      style: style.copyWith(color: HelpColors.grey),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      c.tapArea(left: 17, top: 395, width: 361, height: 8, onTap: _descriptionFocus.requestFocus),

      // حدّد المكان أو أرفق موقعك الحالي (📍 Vector 13×18)
      ...ReportField.build(
        c,
        box: const Rect.fromLTWH(17, 449, 361, 53),
        text: state.locating
            ? LostChildText.locating()
            : report.location == null
            ? LostChildText.locationHint()
            : LostChildText.locationAttached(),
        empty: report.location == null,
        textRight: 341,
        textTop: 465,
        hintWidth: 177,
        room: 300,
        onTap: _attachLocation,
        leading: [c.image('assets/images/help/ic_pin.png', left: 347, top: 466, width: 15, height: 20, color: HelpColors.green)],
      ),

      // صورة الطفل (اختياري) — بعد الاختيار الصورة نفسها مكان الأيقونة
      ...ReportField.build(
        c,
        box: const Rect.fromLTWH(17, 548, 361, 53),
        text: photo == null ? LostChildText.photoHint() : LostChildText.photoAttached(),
        empty: photo == null,
        textRight: 330,
        textTop: 564,
        hintWidth: 145,
        room: 290,
        onTap: _pickPhoto,
        leading: [
          if (photo == null)
            c.image('assets/images/help/ic_photo_add.png', left: 337, top: 563, width: 24, height: 24, color: HelpColors.green)
          else
            c.rect(
              left: 335,
              top: 561,
              width: 28,
              height: 28,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(c.s.x(5)),
                child: Image.file(File(photo), fit: BoxFit.cover, cacheWidth: 120, errorBuilder: (_, _, _) => const SizedBox()),
              ),
            ),
        ],
      ),
    ];
  }
}
