import '../../../../core/l10n/countries.dart';
import '../../../../core/utils/json_fields.dart';
import '../../domain/entities/group_member.dart';
import '../../domain/entities/supervisor_group.dart';
import '../../domain/entities/trip_program.dart';
import '../../presentation/widgets/supervisor_format.dart';

// -------------------------------------------------------------
// تحويل ردود السيرفر للمشرف إلى كيانات الواجهة
// الأرقام: GroupMemberRole (1 مشرف، 2 معتمر) — AttendanceStatus (1 حاضر، 2 غائب) — Gender (1 ذكر، 2 أنثى)
// -------------------------------------------------------------
abstract final class SupervisorServerJson {
  static String? _opt(Map<String, dynamic> j, String name) {
    final v = j.field(name)?.toString().trim();
    return v == null || v.isEmpty ? null : v;
  }

  /// الرحلة القادمة بكرت الرئيسية: أقرب نشاط جاي من برنامج الرحلة ("الاستعداد للعمرة" / "06:00 صباحًا : نقطة التجمع")
  /// بلا برنامج: اسم الرحلة وتاريخ الذهاب
  static ({String title, String details}) nextActivity(Map<String, dynamic> group, Map<String, dynamic>? itinerary, {DateTime? now}) {
    final n = now ?? DateTime.now();
    for (final day in (itinerary?.field('days') as List?)?.whereType<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[]) {
      final date = DateTime.tryParse(day.field('date')?.toString() ?? '');
      if (date == null || date.isBefore(DateTime(n.year, n.month, n.day))) continue;
      for (final a in (day.field('activities') as List?)?.whereType<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[]) {
        final at = DateTime.tryParse(a.field('timeUtc')?.toString() ?? '')?.toLocal();
        if (at != null && at.isBefore(n)) continue;
        final place = _opt(a, 'place');
        final when = at == null ? SupFormat.date(date) : SupFormat.longTime(at);
        return (title: _opt(a, 'title') ?? '', details: place == null ? when : '$when : $place');
      }
    }
    final trip = _opt(group, 'tripName');
    final departure = DateTime.tryParse(group.field('departureDate')?.toString() ?? '');
    return (title: trip ?? '', details: departure == null ? '' : SupFormat.date(departure));
  }

  static SupervisorGroup group(Map<String, dynamic> j, {Map<String, dynamic>? itinerary, DateTime? now}) {
    final next = nextActivity(j, itinerary, now: now);
    return SupervisorGroup(
      id: j.requireString('id'),
      name: _opt(j, 'name') ?? '',
      totalPilgrims: j.optionalInt('pilgrimCount') ?? 0,
      presentCount: j.optionalInt('presentCount') ?? 0,
      absentCount: j.optionalInt('absentCount') ?? 0,
      nextTripTitle: next.title,
      nextTripDetails: next.details,
    );
  }

  /// GroupMemberRowDto / GroupMemberDetailsDto
  static GroupMember member(Map<String, dynamic> j) {
    final gender = j.optionalInt('gender');
    final attendance = j.optionalInt('attendanceStatus');
    return GroupMember(
      id: j.requireString('userId'),
      name: _opt(j, 'fullName') ?? _opt(j, 'email') ?? '',
      photo: _opt(j, 'photoUrl'),
      present: attendance == null ? null : attendance == 1,
      number: j.optionalInt('memberNumberInGroup'),
      gender: gender == 1 ? MemberGender.male : (gender == 2 ? MemberGender.female : null),
      email: _opt(j, 'email'),
      nationality: CompanyCountries.label(_opt(j, 'nationality')),
      health: _opt(j, 'healthNotes'),
      notes: _opt(j, 'notes'),
    );
  }

  static bool isSupervisorRow(Map<String, dynamic> j) => j.optionalInt('role') == 1;

  /// TripItineraryDto → أيام البرنامج ("اليوم 1 — 12 أكتوبر 2026")
  static List<TripDay> program(Map<String, dynamic> itinerary) {
    final days = (itinerary.field('days') as List?)?.whereType<Map<String, dynamic>>().toList() ?? const <Map<String, dynamic>>[];
    return [
      for (final (i, d) in days.indexed)
        TripDay(
          number: i + 1,
          dateLabel: DateTime.tryParse(d.field('date')?.toString() ?? '') == null ? '' : SupFormat.date(DateTime.parse(d.field('date').toString())),
          activities: [
            for (final a in (d.field('activities') as List?)?.whereType<Map<String, dynamic>>() ?? const <Map<String, dynamic>>[])
              TripActivity(
                time: switch (DateTime.tryParse(a.field('timeUtc')?.toString() ?? '')) { final t? => SupFormat.longTime(t.toLocal()), null => '' },
                title: _opt(a, 'title') ?? '',
                place: _opt(a, 'place') ?? '',
                kind: (_opt(a, 'place') ?? '').contains('الحرم') || (_opt(a, 'place') ?? '').toLowerCase().contains('haram') ? ActivityPlace.haram : ActivityPlace.hotel,
              ),
          ],
        ),
    ];
  }
}
