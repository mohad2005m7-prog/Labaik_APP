import '../../../../core/utils/json_fields.dart';
import '../../../supervisor/presentation/widgets/supervisor_format.dart';
import '../../domain/entities/company_group.dart';
import '../../domain/entities/company_member.dart';
import '../../domain/entities/company_notification.dart';
import '../../domain/entities/company_profile.dart';
import '../../domain/entities/company_trip.dart';
import '../../presentation/l10n/company_notifications_text.dart';

// -------------------------------------------------------------
// تحويل ردود /company إلى كيانات الواجهة
// الـ enums أرقام: PilgrimageType (1 عمرة، 2 حج) — TripStatus (1 قادمة، 2 راحلة) — GroupMemberRole (1 مشرف، 2 عضو)
// AttendanceStatus (1 حاضر) — والتواريخ DateOnly "yyyy-MM-dd"
// -------------------------------------------------------------
abstract final class CompanyJson {
  static String _str(Map<String, dynamic> j, String name) => j.field(name)?.toString() ?? '';

  static String? _opt(Map<String, dynamic> j, String name) {
    final v = j.field(name)?.toString().trim();
    return v == null || v.isEmpty ? null : v;
  }

  static DateTime? _date(Map<String, dynamic> j, String name) {
    final v = j.field(name);
    return v is String ? DateTime.tryParse(v) : null;
  }

  /// "20 – 30 نوفمبر 2026" (نفس الشهر) — "28 نوفمبر – 5 ديسمبر 2026" — "15 ديسمبر 2026" (بلا عودة)
  static String dates(DateTime? from, DateTime? to) {
    if (from == null) return '';
    if (to == null || to == from) return SupFormat.date(from);
    if (from.year == to.year && from.month == to.month) return '${from.day} – ${SupFormat.date(to)}';
    if (from.year == to.year) return '${SupFormat.dayMonth(from)} – ${SupFormat.date(to)}';
    return '${SupFormat.date(from)} – ${SupFormat.date(to)}';
  }

  /// "yyyy-MM-dd" للسيرفر (DateOnly)
  static String dateOnly(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// TripSummaryDto أو TripDto — [destinations] من TripDto (الملخص ما فيه وجهات)
  static CompanyTrip trip(Map<String, dynamic> j, {List<String>? destinations}) {
    final from = _date(j, 'departureDate');
    final to = _date(j, 'returnDate');
    final list = destinations ?? [for (final d in (j.field('destinations') as List?) ?? const []) d.toString()];
    return CompanyTrip(
      id: _str(j, 'id'),
      title: _str(j, 'name'),
      destinations: list.join('، '),
      dates: dates(from, to),
      status: j.optionalInt('status') == 2 ? CompanyTripStatus.departed : CompanyTripStatus.upcoming,
      departureDate: from,
      returnDate: to,
      kind: j.optionalInt('pilgrimageType') == 2 ? PilgrimageKind.hajj : PilgrimageKind.umrah,
    );
  }

  static List<String> destinationsOf(Map<String, dynamic> j) => [for (final d in (j.field('destinations') as List?) ?? const []) d.toString()];

  static Map<String, dynamic> tripBody(TripDraft d) => {
        'name': d.name.trim(),
        'pilgrimageType': d.kind == PilgrimageKind.hajj ? 2 : 1,
        'destinations': [for (final x in d.destinations) x.trim()],
        'departureDate': dateOnly(d.departureDate),
        'returnDate': d.returnDate == null ? null : dateOnly(d.returnDate!),
        'departurePlace': d.departurePlace.trim(),
        'expectedPilgrims': d.expectedPilgrims,
        'notes': (d.notes?.trim().isEmpty ?? true) ? null : d.notes!.trim(),
      };

  /// CompanyGroupDto — [trip] للاسم والحالة (السيرفر ما بيرجعهم مع المجموعة)
  static CompanyGroup group(Map<String, dynamic> j, {CompanyTrip? trip, DateTime? today}) => CompanyGroup(
        id: _str(j, 'id'),
        name: _str(j, 'name'),
        tripId: _str(j, 'tripId'),
        tripName: trip?.title ?? _opt(j, 'tripName') ?? '',
        joinCode: _str(j, 'joinCode'),
        supervisorName: _opt(j, 'supervisorName'),
        memberCount: j.optionalInt('pilgrimCount') ?? 0,
        status: trip != null && trip.endedOn(today ?? DateTime.now()) ? CompanyGroupStatus.ended : CompanyGroupStatus.active,
        hajj: trip?.isHajj ?? false,
      );

  static CompanyProfile profile(Map<String, dynamic> j) => CompanyProfile(
        id: _str(j, 'id'),
        name: _str(j, 'name'),
        logoUrl: _opt(j, 'logoUrl'),
        licenseNumber: _str(j, 'commercialRegistrationNumber'),
        country: _opt(j, 'country'),
        city: _opt(j, 'city'),
        email: _opt(j, 'officialEmail'),
        phone: _opt(j, 'primaryPhone'),
        contactName: _str(j, 'contactFullName'),
        supportEmail: _opt(j, 'supportEmail'),
      );

  /// UpdateMyCompanyCommand — الفاضي بيروح null
  static Map<String, dynamic> profileBody(CompanyProfile p) {
    String? opt(String? v) => v == null || v.trim().isEmpty ? null : v.trim();
    return {
      'name': p.name.trim(),
      'commercialRegistrationNumber': p.licenseNumber.trim(),
      'contactFullName': p.contactName.trim(),
      'logoUrl': opt(p.logoUrl),
      'country': opt(p.country),
      'city': opt(p.city),
      'officialEmail': opt(p.email),
      'primaryPhone': opt(p.phone),
    };
  }

  static CompanyMember member(Map<String, dynamic> j) => CompanyMember(
        userId: _str(j, 'userId'),
        name: _opt(j, 'fullName') ?? _opt(j, 'email') ?? '',
        email: _opt(j, 'email'),
        isSupervisor: j.optionalInt('role') == 1,
        number: j.optionalInt('memberNumberInGroup'),
        nationality: _opt(j, 'nationality'),
        photoUrl: _opt(j, 'photoUrl'),
        present: j.optionalInt('attendanceStatus') == 1,
        healthNotes: _opt(j, 'healthNotes'),
        notes: _opt(j, 'notes'),
      );

  static CompanySupervisor supervisor(Map<String, dynamic> j) => CompanySupervisor(
        userId: _str(j, 'userId'),
        name: _opt(j, 'fullName') ?? _str(j, 'email'),
        email: _str(j, 'email'),
        phone: _opt(j, 'phoneNumber'),
        groupsCount: j.optionalInt('groupsCount') ?? 0,
        suspended: j.field('isDisabled') == true || j.field('isSuspended') == true,
      );

  /// NotificationDto — للشركة: 3 مجموعة جديدة، 4 تفعيل مشرف، 5 مجموعة بلا مشرف،
  /// 13/14 مشرف أضاف/شال معتمر (preview = اسم المعتمر) — والباقي بعنوان عام
  /// 3 و5 بالكرت الأغمق (زي Figma: "تم إنشاء مجموعة جديدة")
  static CompanyNotification? notification(Map<String, dynamic> j) {
    final created = DateTime.tryParse(_str(j, 'createdAtUtc'))?.toLocal();
    final id = _str(j, 'id');
    if (created == null || id.isEmpty) return null;
    final type = j.optionalInt('type') ?? 0;
    return CompanyNotification(
      id: id,
      title: CompanyNotificationsText.titleFor(type),
      body: _opt(j, 'preview') ?? '',
      important: type == 3 || type == 5,
      createdAt: created,
    );
  }
}
