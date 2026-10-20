# لبيك: شو ضايل بعد فرع `feat/pending-2026-10-20` (21 أكتوبر 2026)

> يعطيك العافية يا إبراهيم. طبّقنا كل اللي بفرعك على التطبيق والداشبورد.
> هذا الملف بيحكي: مشكلة الدمج مع `main`، شو اشتغل عنّا، وشو ضايل.

---

## 0. مهم قبل الدمج: فرعك بيتعارض مع `main`

`main` فيه PR #2 (تحكم الشركة بالمشرفين). فرعك انعمل من قبله، وفي 3 تعارضات:
- `CompanyEndpoints.cs`
- `IdentityService.cs`
- `docs/openapi/v1.json`

وكمان في **مسارين بنفس الرابط**: `POST /company/supervisors/{userId}/temp-password`. واحد بفرعك وواحد بـ `main`، وهذا بيكسر التشغيل.

**حلّيناها بفرع جاهز:** `mohad2005m7-prog/labaik` → `merge/main-into-pending-2026-10-20`

- خلّينا **نسختك** من كلمة المرور المؤقتة (`IssueSupervisorTempPasswordCommand`)، لأنها بتعمل `mustChangePassword`.
- شلنا النسخة المكررة من `main`: الـ command، والـ overload بـ `IIdentityService`، و`AccountEmails.TemporaryPassword`.
- `BuildAuthUserAsync` صار يفحص الثلاثة مع بعض: الحساب معطّل + المشرف موقوف + `mustChangePassword`.
- تيست الإيقاف صار يدخل بكلمة المرور الجديدة، لأن أول دخول صار يغيّر المؤقتة.
- الـ OpenAPI snapshot انعمل من جديد.
- النتيجة: 82 domain + 78 integration كلهم ناجحين، والـ Release build بلا تحذيرات.

رابط الـ PR (على فرعك):
https://github.com/im-tayeh/Labaik/compare/feat/pending-2026-10-20...mohad2005m7-prog:labaik:merge/main-into-pending-2026-10-20

---

## 1. شو صار شغّال بالتطبيق (Flutter)

| من فرعك | بالتطبيق |
| --- | --- |
| `mustChangePassword` + `POST /auth/change-password` | شاشة «تغيير كلمة المرور» الإجبارية بعد الدخول وعند فتح التطبيق (من claim `pwd_change`) |
| `POST /auth/logout` | تسجيل الخروج بيلغي الـ refresh token (شركة / مشرف / معتمر) |
| أكواد `Auth.AccountDisabled` و`Supervisor.Suspended` و`Auth.EmailNotConfirmed` | رسائل واضحة بشاشة الدخول |
| `GET /company/groups` | كل المجموعات بطلب واحد (ولو السيرفر أقدم بنرجع لكل رحلة لحالها) |
| `destinations` بقائمة الرحلات | ما عاد في طلب تفاصيل لكل رحلة |
| إشعارات 13 و14 | عناوين: «أضاف المشرف معتمراً» / «أزال المشرف معتمراً» |
| `POST/DELETE /groups/{id}/members` | المشرف بيضيف معتمر بالإيميل، وبالضغط المطوّل بيشيله |
| `tripDate` بـ `GroupSummaryDto` | سطر «تاريخ الرحلة» بشاشة «تأكد من مجموعتك» |
| `PUT /rituals/progress` | كل خطوة وشوط بالطواف والسعي بينحفظ، ولو انسكّر التطبيق بيسأله «تتابع من الشوط …؟» |
| `GET/PUT /me/budget` | الميزانية بتنحفظ عالجهاز (بلا نت) وبتنرفع، وعلى جهاز جديد بتنزل من السيرفر |
| `supportEmail` بـ `/company/me` | بشاشة «المساعدة والدعم» |
| `Admin` ما عاد مشرف | حساب Admin لحاله = لوحة الويب بس، و Admin + Supervisor = مشرف |

## 2. شو صار شغّال بالداشبورد

- حساب الأدمن الأول بكلمة مؤقتة: شاشة «تغيير كلمة المرور» قبل اللوحة.
- حذف الشركة: لو رجع 409 `Company.HasActiveTrips` بيطلع زر «حذف رغم وجود رحلات جارية» (`?force=true`).
- كلمة مؤقتة للشركة: بتبيّن إذا انبعت الإيميل (`emailSent`).
- إضافة شركة:
  - الشعار والعقد بينرفعوا على `POST /files` وبينبعت الرابط.
  - كلمة المرور المكتوبة صارت هي اللي بتنستعمل.
  - لو البريد مسجّل من قبل بنوضّح إنه بيدخل بكلمته.

---

## 3. شو ضايل عندك (بالترتيب)

1. **مجموعة الشركة:**
   - `PUT /company/groups/{id}`: الاسم، `notes?`، `capacity?` («اضافة المعتمرون: العدد» بـ Figma).
   - `DELETE /company/groups/{id}`: يرجّع 409 لو فيها أعضاء.
2. **`GET /company/pilgrims`:** كل معتمري الشركة (لاختيار معتمر موجود بدل كتابة الإيميل).
3. **تطبيق القيود (بند 25):**
   - شركة موقوفة أو منتهية: دخولها ودخول مشرفيها بيرجّع 403 `Company.Stopped` / `Company.Expired`. حالياً ما في ولا كود منهم.
   - الخدمة المقفلة (`enabledServices`): بترجّع 403 `Company.ServiceDisabled`.
4. **الدردشات (بند 10):**
   - الدردشة الفردية بين المعتمر ومشرفه: `/chats`.
   - تحكم المشرف بدردشة المجموعة: حذف رسالة، كتم، «المشرف بس بيكتب».
   - الشركة بتقرأ دردشة مجموعاتها، قراءة بس.
5. **`pendingRequests`** بـ `/admin/overview`: لسا ما في طلبات اشتراك. يا إما تنعمل، يا إما تنشال.
6. **`ownerEmail` و`officialEmail`:** لسا بنبعت نفس القيمة للحقلين. قلّي إذا لازم ينفصلوا.
7. **Google Client IDs** على Render، و**FCM** (إشعارات وهو مسكّر).
8. **`supervisorUserId` بـ `CompanyGroupListItemDto`:** حالياً بنلاقي المشرف باسمه، فلو مشرفين بنفس الاسم ممكن نفتح الغلط.

## 4. إعدادات Render (لازم تنحط حتى يشتغل اللي عملته)

- `Storage__ServiceUrl`، `Storage__Bucket`، `Storage__AccessKey`، `Storage__SecretKey`، `Storage__PublicBaseUrl`: بدونهم `POST /files` ما بيشتغل.
- `Cors__Origins__0` = رابط الداشبورد.
- `Support__Email` = بريد الدعم.
- `AppLinks__DownloadUrl` = رابط تحميل التطبيق اللي بيطلع بالإيميلات.
- `Admin__Emails__0`.
- `Email__Provider=Brevo` + المفتاح: بدونها كلمة المرور المؤقتة ورمز الاستعادة بيضلوا بالـ logs بس.

## 5. جرّبه بحساب حقيقي

رمز الاستعادة صار 15 دقيقة، و`Otp.Expired` صار منفصل عن `Otp.Invalid`. ضايل تتأكد إنه **بيوصل الإيميل فعلياً** لكل دور: شركة ومشرف ومعتمر وأدمن.
