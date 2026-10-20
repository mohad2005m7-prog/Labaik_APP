import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/data/account_registry.dart';

// -------------------------------------------------------------
// تقدّم المعتمر بمراحل التعلم (الإحرام ← الطواف ← السعي ← التحلّل) — كل حساب لحاله: learning_progress:<email>
// القيمة = عدد المراحل اللي خلّصها (0..4): المرحلة بتخلص لما يضغط "التالي" (أو "تمت العمرة" بآخر مرحلة)
// -------------------------------------------------------------
class LearningProgressSource {
  static const stages = 4;

  Future<String> _key() async => 'learning_progress:${await AccountRegistry.currentEmail() ?? ''}';

  Future<int> completed() async => ((await SharedPreferences.getInstance()).getInt(await _key()) ?? 0).clamp(0, stages);

  /// المرحلة [index] (من 0) خلصت — التقدّم ما بيرجع لورا لو رجع يراجع مرحلة قبل
  Future<void> complete(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final key = await _key();
    final done = (index + 1).clamp(0, stages);
    if (done > (prefs.getInt(key) ?? 0)) await prefs.setInt(key, done);
  }
}
