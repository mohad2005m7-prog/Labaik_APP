import '../entities/group_info.dart';
import '../entities/group_location_event.dart';
import '../entities/group_member.dart';

// -------------------------------------------------------------
// المجموعة: معلوماتها ونقطة التجمع، أفرادها (المشرف أول)، مواقعهم لحظة بلحظة، وتأكيد وصولي لنقطة التجمع
// -------------------------------------------------------------
abstract class GroupRepository {
  /// null = مش مضاف لمجموعة (الشركة هي اللي بتضيف الأعضاء)
  Future<GroupInfo?> group();

  /// الأفراد ومنهم أنا (isMe) — القائمة بتعرض غيري والخريطة بتعرض الكل
  Future<List<GroupMember>> members();

  /// "نعم، وصلت"
  Future<void> confirmArrival();

  /// مواقع الأفراد لحظة وصولها (بعد ما الشاشة تجيب الحالة الكاملة من [members])
  Stream<GroupLocationEvent> liveLocations();

  /// الاتصال اللحظي شغّال؟ (لو لا، الشاشة بتتحدّث كل 15 ثانية)
  bool get isLive;
}
