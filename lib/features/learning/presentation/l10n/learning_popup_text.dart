import '../../../../core/l10n/tx.dart';

/// نوافذ مراحل التعلم ("Success Screen" بـ Figma) — "\n" مكان كسر سطور Figma
abstract final class LearningPopupText {
  // المحظورات الخاصة بالرجال (248:9883) — نقطتين
  static const menTitle = Tx('المحظورات الخاصة بالرجال', 'Prohibitions for men');
  static const menSewn = Tx(
    'لبس المخيط : يُمنع لبس كل ما فُصل على قدر العضو أو الجسم\nكالقميص، والسراويل، والبلوزات، والجوارب، والأحذية المغلقة\n(ويُستثنى منها النعل المفتوح الذي يكشف الكعبين).',
    'Sewn clothing: anything tailored to the body or a limb is not allowed, such as shirts, trousers, blouses, socks and closed shoes (open sandals that show the heels are allowed).',
  );
  static const menHead = Tx(
    'تغطية الرأس : يُمنع تغطية الرأس بشيء ملاصق لها كالعمامة،\nوالطاقية، والقبعة (ويجوز الاستظلال بالمظلات أو سقف السيارة أو\nالخيمة دون ملامسة الرأس)',
    'Covering the head: anything touching the head, such as a turban, cap or hat, is not allowed (shade from umbrellas, a car roof or a tent that does not touch the head is fine)',
  );

  // المحظورات الخاصة بالنساء (248:9901)
  static const womenTitle = Tx('المحظورات الخاصة بالنساء', 'Prohibitions for women');
  static const womenFace = Tx(
    'تغطية الوجه (النقاب أو البرقع) : يُمنع على المرأة المحرمة لبس\nالنقاب أو البرقع الذي فُصّل لتغطية الوجه. (ولكن يجوز لها -بل\nيجب عليها عند وجود رجال أجانب- أن تسدل خمارها أو شيلتها\nمن فوق رأسها على وجهها دون عقد أو خياطة).',
    'Covering the face (niqab or burqa): a woman in Ihram may not wear a niqab or burqa made to cover the face. (But she may - and must, when unrelated men are present - let her veil hang from above her head over her face, without tying or sewing it).',
  );
  static const womenGloves = Tx(
    'لبس القفازين : يُحرم على المرأة تغطية كفيها بلبس القفازين\n(الشرابات الخاصة باليدين).',
    'Wearing gloves: a woman may not cover her hands with gloves (hand socks).',
  );

  // ماذا لو انتقض وضوئي أو نسيت عدد الأشواط؟ (248:9858)
  static const wuduTitle = Tx('ماذا لو انتقض وضوئي أو نسيت عدد\nالأشواط؟', 'What if I lose my wudu or forget\nthe number of rounds?');
  static const wuduBody = Tx(
    'إذا انتقض وضوؤك، اخرج وتوضأ ثم عُد وأكمل من حيث توقفت (أو ابدأ\nشوطاً جديداً احتياطاً). وإذا شككت في عدد الأشواط (هل هي 3 أم 4؟)،\nابْنِ على اليقين وهو الرقم الأقل (أي اعتبرها 3) وأكمل.',
    'If you lose your wudu, make wudu and continue where you stopped (or start a new round to be safe). If unsure of the count, take the lower number and continue.',
  );

  // شروط وأحكام السعي (249:4065 — عنوانه بـ Figma "الشروط والأحكام السعي" فانصلح متل زر الشاشة)
  static const saiTitle = Tx('شروط وأحكام السعي', "Sa'i rules");
  static const saiBody = Tx(
    'الإرشاد: لا تشترط الطهارة (الوضوء) لصحة السعي، فلو انتقض وضوؤك\nبعد الطواف يمكنك السعي وصحّت عمرتك. السعي لا يوجد فيه\nاضطباع (غطِّ كتفك الأيمن قبل البدء).',
    "Guidance: purity (wudu) is not required for Sa'i, so if you lose your wudu after Tawaf you can still do Sa'i and your Umrah is valid. There is no Idtiba in Sa'i (cover your right shoulder before you start).",
  );

  // مبروك إتمام العمرة (249:4729)
  static const doneTitle = Tx('مبروك إتمام العمرة', 'Congratulations on your Umrah');
  static const doneBody = Tx(
    'الإرشاد: بمجرد الحلق أو التقصير، ينتهي الإحرام تماماً ويحل لك كل ما\nكان محظوراً عليك. يُستحب ختم العمرة بحمد الله والاستغفار وطلب\nالقبول.',
    'Guidance: once you shave or trim, Ihram is fully over and everything that was prohibited is allowed again. It is recommended to end Umrah by praising Allah, seeking forgiveness and asking for acceptance.',
  );
}
