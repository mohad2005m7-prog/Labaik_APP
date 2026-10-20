# لبيك — المطلوب من الباك إند للـ MVP الأول

**إلى:** إبراهيم (Backend — ASP.NET Core 8 / C#)
**التاريخ:** 18 أكتوبر 2026
**النطاق:** التسجيل وتسجيل الدخول بالتوجيه الديناميكي، ولوحة السوبر أدمن، والانضمام للمجموعة، وتتبع المجموعة، والدردشات.

> النسخة السابقة من هذا الملف (النواقص الأخرى مثل نقطة التجمع والحضور وبرنامج الرحلة) محفوظة في `docs/backend_pending_2026-10-16.md`. ليست ضمن هذا الـ MVP.

---

## 0. الفكرة باختصار

1. **انحذفت شاشة «نوع الحساب»** من التطبيق. المستخدم لا يختار نوعه.
2. **تسجيل دخول واحد للجميع.** السيرفر يرجع الـ `role` المسجّل في قاعدة البيانات، والتطبيق يفتح الواجهة حسبه تلقائياً.
3. **من يُنشئ أي حساب:**

| الدور | كيف ينشأ الحساب | أول دخول |
|---|---|---|
| `SuperAdmin` | أصحاب تطبيق لبيك (Seed في قاعدة البيانات) | — |
| `CompanyAdmin` | السوبر أدمن من الداشبورد (الويب) | كلمة مرور مؤقتة ← تغيير إجباري |
| `Supervisor` | الشركة من حسابها («إضافة مشرف» بالإيميل) | كلمة مرور مؤقتة ← تغيير إجباري |
| `Pilgrim` | **هو وحده** يسجّل بنفسه (`register`) | تأكيد الإيميل بالرمز |

4. **أي شيء مفعّل يكون مربوطاً عند الجميع.** رسالة يرسلها المشرف تصل للحاج فوراً والعكس، وموقع الحاج يظهر للمشرف وأعضاء المجموعة. أريد أن أجرّب الدردشة فعلياً بين حساب مشرف وحساب حاج.

---

## 1. قواعد عامة لكل الـ API

- **الأساس:** `https://labaik-api.onrender.com/api/v1` — والوقت الحقيقي تحت `wss://labaik-api.onrender.com/hubs/...`
- **التوثيق:** `Authorization: Bearer <accessToken>` لكل شيء عدا التسجيل والدخول.
- **SignalR:** التطبيق يتصل بـ WebSocket مباشرة **بدون negotiate**، والتوكن في `?access_token=`. لازم تبقى WebSockets مفعّلة على Render.
- **شكل الرد الموحّد** (التطبيق يقرأ `data` إذا وُجد):

```json
{ "success": true, "message": "OK", "data": { } }
```

- **شكل الخطأ الموحّد:**

```json
{ "success": false, "message": "رمز المجموعة غير صحيح", "errorCode": "GROUP_NOT_FOUND", "errors": { "code": ["..."] } }
```

- **أكواد HTTP:** `400` بيانات خاطئة، `401` توكن منتهي (التطبيق يجدّد مرة ويعيد الطلب)، `403` لا صلاحية أو ميزة مقفلة، `404` غير موجود، `409` تكرار.
- **مهم:** «لا يوجد» ليس خطأ. مثلاً حاج بلا مجموعة ← `200` و`"group": null`، وليس `404`.
- **التواريخ:** ISO-8601 بتوقيت UTC، مثل `"2026-09-15T00:00:00Z"`.
- **المعرّفات:** `Guid` كنص.

---

## 2. التسجيل وتسجيل الدخول (أول شيء)

> المسارات الحالية في التطبيق تحت `/api/v1/auth`. أبقها كما هي.

### 2.1 تسجيل حاج/معتمر جديد — `POST /auth/register`
للـ `Pilgrim` فقط. أي محاولة لإنشاء دور آخر من هنا ممنوعة.

```json
// Request
{ "fullName": "محمد أحمد", "email": "pilgrim@example.com", "password": "Passw0rd!" }
```
```json
// Response 200
{ "success": true, "message": "تم إرسال رمز التحقق إلى بريدك", "data": { "email": "pilgrim@example.com", "requiresVerification": true } }
```
- `409` إذا الإيميل مسجّل: `errorCode: "EMAIL_EXISTS"`.

### 2.2 تأكيد الإيميل — `POST /auth/verify-email`
```json
// Request
{ "email": "pilgrim@example.com", "code": "4821" }
```
```json
// Response 200 = نفس رد تسجيل الدخول (2.4) — الحاج يدخل مباشرة
```

### 2.3 إعادة إرسال الرمز — `POST /auth/resend-code`
```json
{ "email": "pilgrim@example.com" }
```

### 2.4 تسجيل الدخول الموحّد — `POST /auth/login`
للجميع (حاج، مشرف، شركة، سوبر أدمن).

```json
// Request
{ "email": "user@example.com", "password": "Passw0rd!" }
```
```json
// Response 200
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOi...",
    "refreshToken": "8f2c1e...",
    "expiresAt": "2026-10-18T14:00:00Z",
    "mustChangePassword": false,
    "user": {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "fullName": "محمد أحمد",
      "email": "user@example.com",
      "role": "Pilgrim",
      "photoUrl": null,
      "companyId": null,
      "groupId": "9b1d...",
      "isEmailVerified": true
    }
  }
}
```
- **`role`** واحد من: `SuperAdmin` | `CompanyAdmin` | `Supervisor` | `Pilgrim`. ضعه أيضاً داخل الـ JWT كـ claim `role`.
- **`mustChangePassword: true`** للمشرف والشركة عند أول دخول بكلمة مؤقتة ← التطبيق يفتح شاشة «إنشاء كلمة مرور جديدة» قبل أي شيء، وكل الطلبات الأخرى ترجع `403` بـ `errorCode: "PASSWORD_CHANGE_REQUIRED"` حتى يغيّرها.
- **أخطاء:**
  - `401` `INVALID_CREDENTIALS`
  - `403` `EMAIL_NOT_VERIFIED` (للحاج، والتطبيق يفتح شاشة الرمز)
  - `403` `COMPANY_FROZEN` / `COMPANY_EXPIRED` (المشرف والشركة إذا كانت الشركة معطّلة)
  - `403` `ACCOUNT_DISABLED`

**التوجيه في التطبيق:** `Pilgrim` ← رئيسية الحاج، `Supervisor` ← رئيسية المشرف، `CompanyAdmin` ← واجهة الشركة. `SuperAdmin` يستعمل الداشبورد على الويب فقط، والتطبيق يعرض له رسالة «هذا الحساب للوحة التحكم».

### 2.5 الدخول بـ Google — `POST /auth/google`
```json
// Request
{ "idToken": "eyJhbGciOiJSUzI1NiIs..." }
```
- تحقّق من الـ `idToken` عند Google (Audience = Client IDs لأندرويد وiOS وWeb).
- إيميل موجود ← سجّل دخوله بدوره المسجّل. إيميل جديد ← أنشئ **Pilgrim** فقط.
- الرد = نفس 2.4.

### 2.6 تغيير كلمة المرور المؤقتة — `POST /auth/change-password` (جديد)
```json
// Request (Bearer)
{ "currentPassword": "Tmp-7Kx92q", "newPassword": "MyNewPass1!" }
```
```json
// Response 200 = نفس رد تسجيل الدخول (2.4) مع "mustChangePassword": false
```

### 2.7 نسيت كلمة المرور
- `POST /auth/forgot-password` ← `{ "email": "..." }`
- `POST /auth/reset-password` ← `{ "email": "...", "code": "4821", "newPassword": "..." }`

### 2.8 تجديد التوكن — `POST /auth/refresh-token`
```json
{ "refreshToken": "8f2c1e..." }
```
الرد = نفس 2.4 (بما فيه `user.role`).

### 2.9 بياناتي — `GET /auth/me`
الرد = كائن `user` من 2.4.

### 2.10 يُحذف
- `PUT /auth/account-type` لم يعد مستعملاً. احذفه أو أبقه يرجع `410 Gone`.

---

## 3. لوحة السوبر أدمن (أصحاب لبيك — ويب)

كل المسارات تحت `/admin` وتتطلب `role = SuperAdmin`.

### 3.1 قائمة الشركات — `GET /admin/companies?search=&status=&page=1&pageSize=20`
```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "c1...",
        "name": "شركة النور للحج والعمرة",
        "status": "Active",
        "subscriptionStart": "2026-01-01T00:00:00Z",
        "subscriptionEnd": "2026-12-31T00:00:00Z",
        "activePilgrims": 340,
        "maxPilgrims": 500,
        "supervisorsCount": 12,
        "maxSupervisors": 20,
        "groupsCount": 14
      }
    ],
    "page": 1, "pageSize": 20, "total": 1
  }
}
```
`status`: `Active` | `Frozen` | `Expired` (يصبح `Expired` تلقائياً بعد `subscriptionEnd`).

### 3.2 إنشاء شركة — `POST /admin/companies`
```json
// Request
{
  "name": "شركة النور للحج والعمرة",
  "commercialRegistry": "1010123456",
  "taxNumber": "300123456700003",
  "phone": "+966500000000",
  "email": "info@alnoor.sa",
  "city": "الرياض",
  "subscription": {
    "start": "2026-01-01T00:00:00Z",
    "end": "2026-12-31T00:00:00Z",
    "price": 15000,
    "currency": "SAR",
    "maxPilgrims": 500,
    "maxSupervisors": 20
  },
  "admin": {
    "fullName": "خالد العتيبي",
    "email": "khaled@alnoor.sa",
    "phone": "+966511111111",
    "nationalId": "1012345678"
  },
  "sendCredentialsByEmail": true,
  "forcePasswordChange": true
}
```
```json
// Response 201
{
  "success": true,
  "data": {
    "company": { "id": "c1...", "name": "شركة النور للحج والعمرة", "status": "Active" },
    "admin": { "id": "u7...", "email": "khaled@alnoor.sa", "role": "CompanyAdmin" },
    "temporaryPassword": "Tmp-7Kx92q"
  }
}
```
- `temporaryPassword` يظهر **مرة واحدة فقط** في هذا الرد (لينسخه السوبر أدمن ويرسله بالواتس إن أراد). لا يُخزَّن إلا كـ Hash.

### 3.3 تعديل شركة — `PUT /admin/companies/{id}`
نفس جسم 3.2 بدون `admin`.

### 3.4 حالة الشركة — `PUT /admin/companies/{id}/status`
```json
{ "status": "Frozen", "reason": "تأخر السداد" }
```
- `Frozen` أو `Expired` ← كل مستخدمي الشركة (الشركة والمشرفون) يُرفض دخولهم `403 COMPANY_FROZEN`. الحجاج يبقون يرون التطبيق، لكن ميزات المجموعة (التتبع والدردشة) تتوقف.

### 3.5 ميزات الشركة — `PUT /admin/companies/{id}/features`
```json
{
  "gpsTracking": true,
  "groupChat": true,
  "directChat": true,
  "duas": true,
  "instantNotifications": true,
  "reports": false
}
```
- الميزة المقفلة ← السيرفر يرجع `403` بـ `errorCode: "FEATURE_DISABLED"` و`"feature": "gpsTracking"`.
- أضِف الميزات أيضاً في `GET /home` (القسم 4.1) حتى يخفي التطبيق الأزرار المقفلة.

### 3.6 كلمة مرور مؤقتة جديدة للشركة — `POST /admin/companies/{id}/temp-password`
```json
// Request
{ "sendByEmail": true }
```
```json
// Response 200
{ "success": true, "data": { "temporaryPassword": "Tmp-Q2m8Lp", "emailSent": true } }
```
يضع `mustChangePassword = true` ويلغي كل الـ refresh tokens القديمة.

---

## 4. الشركة والمشرفون والمجموعات

### 4.0 إضافة مشرف (حساب الشركة) — `POST /company/supervisors`
`role = CompanyAdmin`.
```json
// Request
{ "fullName": "أحمد محمد", "email": "ahmad@alnoor.sa", "phone": "+966522222222", "sendByEmail": true }
```
```json
// Response 201
{ "success": true, "data": { "id": "s1...", "email": "ahmad@alnoor.sa", "role": "Supervisor", "temporaryPassword": "Tmp-9Hd31x", "emailSent": true } }
```
- الشركة تقدر تنسخ الكلمة المؤقتة وترسلها بالإيميل أو الواتس أو مباشرة.
- يحترم `maxSupervisors` ← `409 SUPERVISOR_LIMIT`.
- كلمة جديدة لمشرف: `POST /company/supervisors/{id}/temp-password` (نفس شكل 3.6).
- القائمة: `GET /company/supervisors`.

### 4.1 الرئيسية للمستخدم — `GET /home` (موجود — أضِف الحقول)
```json
{
  "success": true,
  "data": {
    "user": { "id": "u1...", "fullName": "محمد أحمد", "role": "Pilgrim" },
    "features": { "gpsTracking": true, "groupChat": true, "directChat": true, "duas": true, "instantNotifications": true },
    "group": {
      "id": "g1...",
      "name": "حملة النور",
      "joinCode": "A7K8P2",
      "conversationId": "conv-g1...",
      "supervisor": { "id": "s1...", "fullName": "أحمد محمد", "photoUrl": null },
      "membersCount": 25,
      "tripDate": "2026-09-15T00:00:00Z"
    }
  }
}
```
`group: null` إذا الحاج بلا مجموعة (التطبيق يفتح شاشة «انضم إلى مجموعتك»).

### 4.2 إنشاء مجموعة — `POST /company/groups`
`role = CompanyAdmin` (أو `Supervisor` إذا سمحت الشركة).
```json
// Request
{ "name": "حملة النور", "supervisorId": "s1...", "tripDate": "2026-09-15T00:00:00Z", "maxMembers": 50 }
```
```json
// Response 201
{
  "success": true,
  "data": {
    "id": "g1...",
    "name": "حملة النور",
    "joinCode": "A7K8P2",
    "qrPayload": "labaik://join?code=A7K8P2",
    "qrImageUrl": "https://.../qr/A7K8P2.png",
    "supervisorEmailSent": true
  }
}
```
- `joinCode`: 6 أحرف/أرقام كبيرة، فريد، بدون أحرف ملتبسة (`0 O 1 I`).
- محتوى الـ QR: نص الرمز وحده **أو** رابط فيه `?code=` (التطبيق يقبل الاثنين).
- إيميل للمشرف عبر Brevo/SMTP فيه اسم المجموعة والرمز وصورة الـ QR. **مفتاح Brevo على السيرفر فقط، أبداً ليس في التطبيق.**

### 4.3 معاينة المجموعة قبل الانضمام — `GET /groups/preview?code=A7K8P2`
شاشة «تأكد من مجموعتك» في التطبيق.
```json
{
  "success": true,
  "data": {
    "id": "g1...",
    "code": "A7K8P2",
    "name": "حملة النور",
    "supervisorName": "أحمد محمد",
    "membersCount": 25,
    "tripDate": "2026-09-15T00:00:00Z",
    "companyName": "شركة النور للحج والعمرة"
  }
}
```
- `404 GROUP_NOT_FOUND` رمز غلط. `409 GROUP_FULL` المجموعة ممتلئة.

### 4.4 الانضمام — `POST /groups/join`
`role = Pilgrim`.
```json
// Request
{ "code": "A7K8P2" }
```
```json
// Response 200
{
  "success": true,
  "data": {
    "groupId": "g1...",
    "name": "حملة النور",
    "membersCount": 26,
    "conversationId": "conv-g1..."
  }
}
```
- يضيف الحاج لمحادثة المجموعة تلقائياً.
- يرسل للمشرف عبر `/hubs/events` حدث `MemberJoined` ← `{ "groupId": "g1...", "userId": "u1...", "fullName": "محمد أحمد" }`.
- `409 ALREADY_IN_GROUP` إذا كان في مجموعة (MVP: مجموعة واحدة للحاج).
- مغادرة: `POST /groups/leave` (اختياري للـ MVP).

### 4.5 أعضاء المجموعة — `GET /groups/{groupId}/members`
للمشرف وأعضاء المجموعة نفسها فقط.
```json
{
  "success": true,
  "data": [
    {
      "userId": "s1...",
      "fullName": "أحمد محمد",
      "role": "Supervisor",
      "photoUrl": null,
      "isOnline": true,
      "lastSeenAt": "2026-10-18T12:01:00Z",
      "sharesLocation": true,
      "location": { "lat": 21.4225, "lng": 39.8262, "accuracy": 12.5, "at": "2026-10-18T12:00:40Z" }
    }
  ]
}
```
`location: null` إذا لم يشارك موقعه.

---

## 5. تتبع المجموعة (GPS)

> موجود جزئياً. التطبيق يستعمل `/location` و`/hubs/location`. ثبّت هذا الشكل.

### 5.1 تشغيل/إيقاف المشاركة — `PUT /location/sharing`
```json
{ "enabled": true }
```

### 5.2 إرسال موقعي — `POST /location`
كل 30 ثانية أو 50 متراً، والتطبيق مفتوح.
```json
{ "lat": 21.4225, "lng": 39.8262, "accuracy": 12.5, "heading": 90, "speed": 1.2, "recordedAt": "2026-10-18T12:00:40Z" }
```
```json
{ "success": true, "data": null }
```
- يُحفظ **آخر موقع** لكل مستخدم (`UserLastLocation`) + سجل اختياري (`TrackingLocation`) يُحذف بعد 7 أيام.
- يُرسل فوراً لأعضاء نفس المجموعة عبر `/hubs/location`.
- `403 FEATURE_DISABLED` إذا `gpsTracking` مقفلة.

### 5.3 مواقع المجموعة — `GET /groups/{groupId}/locations`
نفس عناصر 5.4 كقائمة.

### 5.4 Hub الموقع — `wss://.../hubs/location`
- عند الاتصال يضيفه السيرفر لـ SignalR Group اسمها `group:{groupId}`.
- **حدث `LocationUpdated`:**
```json
{ "userId": "u1...", "fullName": "محمد أحمد", "lat": 21.4225, "lng": 39.8262, "accuracy": 12.5, "at": "2026-10-18T12:00:40Z" }
```
- **حدث `StoppedSharing`:** `{ "userId": "u1..." }`

---

## 6. الدردشات (مطلوب يشتغل فعلياً عند المشرف والحاج)

### 6.1 قائمة محادثاتي — `GET /chats`
```json
{
  "success": true,
  "data": [
    {
      "id": "conv-g1...",
      "type": "Group",
      "title": "حملة النور",
      "photoUrl": null,
      "otherUserId": null,
      "lastMessage": { "id": "m9...", "senderId": "s1...", "senderName": "أحمد محمد", "text": "التجمع بعد العصر", "sentAt": "2026-10-18T12:00:00Z" },
      "unreadCount": 3
    },
    {
      "id": "conv-d7...",
      "type": "Direct",
      "title": "أحمد محمد",
      "photoUrl": null,
      "otherUserId": "s1...",
      "lastMessage": null,
      "unreadCount": 0
    }
  ]
}
```

### 6.2 بدء/جلب محادثة فردية — `POST /chats/direct`
```json
// Request
{ "userId": "s1..." }
```
الرد = عنصر واحد من 6.1. لو المحادثة موجودة يرجعها نفسها (لا يكرر).
**الصلاحية:** الحاج ↔ مشرف مجموعته، وأعضاء نفس المجموعة مع بعض. غير ذلك `403`.

### 6.3 الرسائل — `GET /chats/{conversationId}/messages?afterId=&before=&limit=50`
```json
{
  "success": true,
  "data": [
    { "id": "m9...", "conversationId": "conv-g1...", "senderId": "s1...", "senderName": "أحمد محمد", "senderPhotoUrl": null, "text": "التجمع بعد العصر", "sentAt": "2026-10-18T12:00:00Z", "clientId": null }
  ]
}
```
مرتبة من الأقدم للأحدث.

### 6.4 إرسال رسالة — `POST /chats/{conversationId}/messages`
```json
// Request
{ "text": "وصلت", "clientId": "c-1729252800-17" }
```
```json
// Response 201 = رسالة واحدة بشكل 6.3 (مع نفس clientId)
```
- `clientId` يولّده التطبيق لمنع التكرار وربط الرسالة المرسلة بالرد.
- بعد الحفظ، يُرسل فوراً لكل أعضاء المحادثة (عدا المرسل) عبر `/hubs/events`.

### 6.5 مقروء — `POST /chats/{conversationId}/read`
بدون جسم. يصفّر `unreadCount` للمستخدم.

### 6.6 Hub الأحداث — `wss://.../hubs/events`
- عند الاتصال يضيف السيرفر المستخدم لـ `user:{userId}` ولكل `conversation:{id}` هو فيها.
- **حدث `MessageReceived`:** رسالة بشكل 6.3.
- **حدث `ConversationCreated`:** عنصر بشكل 6.1 (عند بدء محادثة فردية جديدة معه).
- **حدث `NotificationReceived`:** إشعار (موجود).

> **مهم للتجربة:** المشرف يرسل في محادثة المجموعة ← تظهر عند كل الحجاج فوراً. الحاج يبدأ محادثة فردية مع المشرف ← تظهر في قائمة المشرف فوراً (`ConversationCreated`) ويتبادلان الرسائل لحظياً.

---

## 7. نماذج قاعدة البيانات (EF Core)

```csharp
public enum UserRole { SuperAdmin, CompanyAdmin, Supervisor, Pilgrim }
public enum CompanyStatus { Active, Frozen, Expired }
public enum ConversationType { Group, Direct }

public class Company {
    public Guid Id { get; set; }
    public string Name { get; set; } = "";
    public string? CommercialRegistry { get; set; }
    public string? TaxNumber { get; set; }
    public string? Phone { get; set; }
    public string? Email { get; set; }
    public string? City { get; set; }
    public CompanyStatus Status { get; set; }
    public string? StatusReason { get; set; }
    public DateTime SubscriptionStart { get; set; }
    public DateTime SubscriptionEnd { get; set; }
    public decimal Price { get; set; }
    public string Currency { get; set; } = "SAR";
    public int MaxPilgrims { get; set; }
    public int MaxSupervisors { get; set; }
    public CompanyFeatures Features { get; set; } = new();   // Owned type
    public DateTime CreatedAt { get; set; }
    public ICollection<User> Users { get; set; } = [];
    public ICollection<Group> Groups { get; set; } = [];
}

[Owned]
public class CompanyFeatures {
    public bool GpsTracking { get; set; } = true;
    public bool GroupChat { get; set; } = true;
    public bool DirectChat { get; set; } = true;
    public bool Duas { get; set; } = true;
    public bool InstantNotifications { get; set; } = true;
    public bool Reports { get; set; }
}

public class User {                       // أو IdentityUser<Guid> مع هذه الحقول
    public Guid Id { get; set; }
    public string FullName { get; set; } = "";
    public string Email { get; set; } = "";
    public string? Phone { get; set; }
    public string PasswordHash { get; set; } = "";
    public UserRole Role { get; set; }
    public bool IsEmailVerified { get; set; }
    public bool MustChangePassword { get; set; }
    public bool IsDisabled { get; set; }
    public string? PhotoUrl { get; set; }
    public Guid? CompanyId { get; set; }          // CompanyAdmin + Supervisor
    public Company? Company { get; set; }
    public Guid? GroupId { get; set; }            // Pilgrim (مجموعة واحدة بالـ MVP)
    public Group? Group { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? LastSeenAt { get; set; }
}

public class Trip {
    public Guid Id { get; set; }
    public Guid CompanyId { get; set; }
    public Company Company { get; set; } = null!;
    public string Title { get; set; } = "";
    public DateTime StartDate { get; set; }
    public DateTime? EndDate { get; set; }
    public ICollection<Group> Groups { get; set; } = [];
}

public class Group {
    public Guid Id { get; set; }
    public Guid CompanyId { get; set; }
    public Company Company { get; set; } = null!;
    public Guid? TripId { get; set; }
    public Trip? Trip { get; set; }
    public Guid SupervisorId { get; set; }
    public User Supervisor { get; set; } = null!;
    public string Name { get; set; } = "";
    public string JoinCode { get; set; } = "";      // Unique index
    public int MaxMembers { get; set; }
    public DateTime? TripDate { get; set; }
    public Guid ConversationId { get; set; }
    public ICollection<User> Members { get; set; } = [];
}

public class Conversation {
    public Guid Id { get; set; }
    public ConversationType Type { get; set; }
    public Guid? GroupId { get; set; }
    public DateTime CreatedAt { get; set; }
    public ICollection<ConversationParticipant> Participants { get; set; } = [];
    public ICollection<ChatMessage> Messages { get; set; } = [];
}

public class ConversationParticipant {   // PK (ConversationId, UserId)
    public Guid ConversationId { get; set; }
    public Guid UserId { get; set; }
    public User User { get; set; } = null!;
    public Guid? LastReadMessageId { get; set; }
    public DateTime JoinedAt { get; set; }
}

public class ChatMessage {
    public Guid Id { get; set; }
    public Guid ConversationId { get; set; }
    public Conversation Conversation { get; set; } = null!;
    public Guid SenderId { get; set; }
    public User Sender { get; set; } = null!;
    public string Text { get; set; } = "";
    public string? ClientId { get; set; }         // Unique (SenderId, ClientId)
    public DateTime SentAt { get; set; }
}

public class TrackingLocation {           // السجل (يُحذف بعد 7 أيام)
    public long Id { get; set; }
    public Guid UserId { get; set; }
    public double Lat { get; set; }
    public double Lng { get; set; }
    public double? Accuracy { get; set; }
    public DateTime RecordedAt { get; set; }
}

public class UserLastLocation {           // PK = UserId — آخر موقع فقط
    public Guid UserId { get; set; }
    public double Lat { get; set; }
    public double Lng { get; set; }
    public double? Accuracy { get; set; }
    public bool SharingEnabled { get; set; }
    public DateTime UpdatedAt { get; set; }
}
```

**العلاقات:**
- `Company 1—* User` (الشركة والمشرفون)، `Company 1—* Group`، `Company 1—* Trip`.
- `Group *—1 User(Supervisor)`، `Group 1—* User(Pilgrims)` عبر `User.GroupId`.
- `Group 1—1 Conversation(Group)`.
- `Conversation 1—* ChatMessage`، `Conversation *—* User` عبر `ConversationParticipant`.
- **Indexes:** `Group.JoinCode` unique، `User.Email` unique، `ChatMessage (ConversationId, SentAt)`، `TrackingLocation (UserId, RecordedAt)`.

---

## 8. خطوات التنفيذ (بالترتيب)

1. **الأدوار والتوكن:** أضف `Role` و`MustChangePassword` و`CompanyId` للمستخدم. ضع `role` في الـ JWT وفي رد `login` / `verify-email` / `refresh-token` / `google`. Seed حساب `SuperAdmin` من متغيرات البيئة.
2. **Policies:** `[Authorize(Roles = "SuperAdmin")]` للـ `/admin`، `CompanyAdmin` للـ `/company`. Middleware يرفض أي طلب بـ `403 PASSWORD_CHANGE_REQUIRED` إذا `MustChangePassword` (عدا `/auth/change-password` و`/auth/me`)، و`403 COMPANY_FROZEN` إذا الشركة غير مفعّلة.
3. **`POST /auth/change-password`** وتعطيل `account-type`.
4. **الداشبورد:** الشركات (3.1 → 3.6) + توليد الكلمة المؤقتة (`RandomNumberGenerator`، 10 خانات) + إيميل Brevo.
5. **المشرفون والمجموعات:** 4.0 و4.2 (رمز + QR بمكتبة `QRCoder`) ثم 4.3 و4.4 و4.5، وتحديث `GET /home`.
6. **التتبع:** 5.1 → 5.4 مع فحص `features.gpsTracking`.
7. **الدردشة:** 6.1 → 6.6. أنشئ `Conversation` للمجموعة مع إنشاء المجموعة، وأضف الحاج له عند الانضمام والمشرف عند الإنشاء.
8. **Migrations:** `dotnet ef migrations add Mvp1 && dotnet ef database update`.
9. **Render:** متغيرات البيئة (`ConnectionStrings__Default`, `Jwt__Key`, `Brevo__ApiKey`, `Google__ClientIds`, `SuperAdmin__Email`, `SuperAdmin__Password`)، وتأكد أن WebSockets مفعّلة.
10. **اختبار سريع:** سجّل حاج ← أنشئ شركة من السوبر ← أضف مشرف ← أنشئ مجموعة ← الحاج ينضم بالرمز ← رسالة من المشرف تصل للحاج لحظياً والعكس ← موقع الحاج يظهر للمشرف.

---

## 9. المطلوب تسليمه لي (مهم)

1. **ملف JSON جاهز يغطي كل المسارات أعلاه**، أحد هذين (والأفضل الاثنين):
   - `swagger.json` (OpenAPI 3) من `/swagger/v1/swagger.json`، مع أمثلة الـ Request/Response.
   - **Postman Collection** (`labaik_mvp1.postman_collection.json`) فيها كل طلب مع مثال رد ناجح ومثال خطأ، ومتغير `{{baseUrl}}` و`{{token}}`.
2. **حسابات تجربة** (ترسلها لي بشكل خاص، لا تضعها في الملف):
   - سوبر أدمن واحد، وشركة واحدة، ومشرف واحد، وحاجّان، ومجموعة فيها الكل برمز معروف.
3. **قائمة `errorCode`** النهائية إذا أضفت أكواداً غير المذكورة.
4. أي اختلاف عن هذا الملف في الأسماء أو الأشكال، اكتبه لي قبل النشر حتى أعدّل التطبيق.
