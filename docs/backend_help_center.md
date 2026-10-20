# مركز المساعدة والدردشات ودائرة العائلة — المطلوب من الباك إند (لبيك)

هذا الملف موجّه لمطوّر الباك إند (ASP.NET Core). التطبيق صار جاهز ومربوط بهالـ endpoints بالظبط، وأول ما تنزل على السيرفر بتشتغل الشاشات بدون أي تعديل بالتطبيق:

- **التواصل السريع مع المشرف:** اسم المشرف، صورته، ورقم جواله الحقيقي للاتصال.
- **الدردشات:**
  - قائمة محادثات المعتمر: مشرفه، مجموعة الحملة، وأفراد المجموعة، مع المثبّتة وعدد غير المقروء.
  - المحادثة نفسها: رسائل فعلية بتوصل لحظياً.
  - المحادثة مع المشرف هي نفسها من «مركز المساعدة» ومن «الدردشات».
- **بلاغ الطفل المفقود:** بيوصل للمشرف، وللمستخدمين القريبين إذا المعتمر وافق على المشاركة.
- **دائرة العائلة (تبويب «الأفراد»):** إنشاء الدائرة برمز و QR، الانضمام بالرمز، أفراد العائلة (متصل / آخر ظهور / الموقع) وخريطتهم، ومشاركة الموقع الفعلي بموافقة كل فرد. القسم 3.8.

---

## 1) التقنيات المقترحة

| الجزء | المقترح | ليش |
|---|---|---|
| API | **ASP.NET Core** (نفس المشروع الحالي `labaik-api`) | الـ auth موجود فيه. |
| الوقت الحقيقي للمحادثة | **SignalR** (موجود جوّا ASP.NET Core) | التطبيق بيتصل فيه مباشرة ببروتوكول JSON فوق WebSocket. |
| قاعدة البيانات | نفس قاعدة البيانات الحالية + **EF Core** | — |
| الصور (صورة الطفل، صور المستخدمين والمجموعات) | **Cloudinary** أو **S3** أو **Supabase Storage** | ⚠️ ملفات Render المجانية بتنمسح مع كل deploy، فما تحفظ الصور على قرص السيرفر. |
| الإشعارات لما التطبيق مسكّر | **Firebase Cloud Messaging** عبر مكتبة `FirebaseAdmin` | المرحلة الجاية؛ التطبيق لسا ما بيسجّل توكن الجهاز. |

---

## 2) قواعد عامة (التطبيق معتمد عليها)

- **الرابط الأساسي:** `https://labaik-api.onrender.com/api/v1`.
- **التوثيق:** كل الطلبات بتوصل مع `Authorization: Bearer <accessToken>`.
  - لو السيرفر رد بـ `401`، التطبيق بيجدّد التوكن بـ `/auth/refresh` الموجود وبيعيد الطلب مرة وحدة.
- **صيغة JSON:** الحقول **camelCase**، والتطبيق بيقبل PascalCase كمان. الرد ممكن يكون الكائن نفسه أو ملفوف بـ `{ "data": ... }`.
- **التواريخ:** ISO 8601 بتوقيت **UTC** مع `Z`، مثل `"2026-10-15T09:41:00Z"`.
- **معنى `404` بالتطبيق: "الـ endpoint مش موجود على السيرفر بعد"**، وبيعرض للمستخدم «هذه الخدمة لسا مش مفعّلة على السيرفر». يعني:
  - المعتمر مش مربوط بمشرف ← رجّع **`200` مع `null`**، مش `404`.
  - ما عنده محادثات ← رجّع **`200` مع `[]`**.
  - مستخدم مش مشارك بالمحادثة ← رجّع `403`.
- **أرقام الجوال:** بصيغة E.164، مثل `+966500000000`.
- **الـ id:** ممكن يكون `Guid` أو رقم، والتطبيق بيتعامل معه كنص.

---

## 3) الـ Endpoints

### 3.1 مشرف المعتمر الحالي (التواصل السريع)

```
GET /api/v1/pilgrim/supervisor
```

**الرد `200`:**

```json
{
  "id": "b3c1…",
  "fullName": "أحمد محمد",
  "phoneNumber": "+966500000000",
  "photoUrl": "https://…/supervisors/b3c1.jpg",
  "conversationId": "7f2a…"
}
```

- **المعتمر لسا مش مربوط بمجموعة أو مشرف** ← `200` والجسم `null`. التطبيق بيكتب «لم يتم ربطك بمشرف مجموعة بعد».
- **`phoneNumber`:** هو الرقم المخزّن بحساب المشرف، أو اللي حاطّته الشركة بقائمة المشرفين. التطبيق بيفتح شاشة الاتصال فيه والرقم جاهز، و`null` = «رقم المشرف غير متوفر حالياً».
- **`conversationId`:** المحادثة الفردية بين المعتمر ومشرفه (نفسها اللي بتطلع بالدردشات). **السيرفر بينشئها أول مرة لحاله** لو مش موجودة، وبيرجّع رقمها دايماً.
- **التطبيق بيحفظ آخر رد على الجهاز**، فالاتصال بالمشرف بيضل شغّال حتى بدون إنترنت.

### 3.2 قائمة المحادثات (تبويب الدردشات)

```
GET /api/v1/chats
```

**الرد `200`:** محادثات المستخدم صاحب التوكن (المعتمر أو المشرف):

```json
[
  {
    "id": "7f2a…",
    "title": "أحمد محمد",
    "photoUrl": "https://…/users/b3c1.jpg",
    "isGroup": false,
    "isPinned": true,
    "unreadCount": 2,
    "lastMessage": { "...": "MessageDto (القسم 3.3)" }
  },
  { "id": "g_12", "title": "مجموعة حملة النور", "photoUrl": "https://…/groups/12.jpg", "isGroup": true, "isPinned": true, "unreadCount": 2, "lastMessage": { } }
]
```

- **`title` / `photoUrl`:** حسب مين بيطلب:
  - **محادثة فردية:** اسم وصورة **الطرف التاني**.
  - **مجموعة:** اسم المجموعة وصورتها.
- **المحادثات اللي لازم تطلع للمعتمر:**
  - محادثته مع **مشرفه** (مثبّتة: `isPinned: true`).
  - **محادثة مجموعة الحملة** (مثبّتة، `isGroup: true`).
  - **المحادثات الفردية مع أفراد المجموعة** اللي فيها رسائل.
- **`unreadCount`:** رسائل الطرف التاني اللي بعد آخر قراءة للمستخدم (القسم 3.5).
- **الترتيب:** التطبيق بيرتّب لحاله (المثبّتة فوق وبعدين الأحدث)، فالترتيب من السيرفر مش مهم.

### 3.3 رسائل المحادثة

```
GET /api/v1/chats/{conversationId}/messages?afterId={messageId}
```

- **بدون `afterId`:** آخر 100 رسالة، مرتّبة **تصاعدياً** حسب `sentAt`.
- **مع `afterId`:** بس الرسائل الأحدث من هالرسالة. التطبيق بيطلبها كل 4 ثواني لما الاتصال اللحظي مقطوع، وكل 20 ثانية كاحتياط.
- **مستخدم مش مشارك بالمحادثة** ← `403`.

**الرد `200`:** مصفوفة `MessageDto`:

```json
[
  {
    "id": "m_101",
    "conversationId": "7f2a…",
    "clientId": "c1729000000000123456",
    "senderId": "u_55",
    "senderName": "سارة علي",
    "senderPhotoUrl": "https://…/users/u_55.jpg",
    "isMine": false,
    "text": "عند البوابة المحددة من المشرف.",
    "latitude": null,
    "longitude": null,
    "sentAt": "2026-10-15T09:41:00Z"
  }
]
```

- **`isMine`:** يُحسب للمستخدم اللي طالب (صاحب التوكن). لو ما انبعت، التطبيق بيقارن `senderId` مع `sub` بالـ JWT.
- **`senderName` / `senderPhotoUrl`:** صورة المرسل بتطلع جنب فقاعته، وبالمجموعة كل واحد بصورته.
- **`conversationId`:** لازم يكون موجود؛ قائمة المحادثات بتتحدّث فيه لحظياً.
- **رسالة الموقع:** فيها `latitude` و`longitude`، و`text` ممكن يكون `null`.

### 3.4 إرسال رسالة

```
POST /api/v1/chats/{conversationId}/messages
Content-Type: application/json
```

```json
{ "clientId": "c1729000000000123456", "text": "أنا تائه", "latitude": null, "longitude": null }
```

- **الرد:** `201` (أو `200`) مع نفس `MessageDto` اللي فوق، ومعه `clientId` نفسه.
- **التحقق:** لازم `text` أو (`latitude` + `longitude`). أقصى طول للنص 2000 حرف.
- **⚠️ منع التكرار (idempotency):** التطبيق بيعيد إرسال الرسالة اللي ما وصلت **بنفس `clientId`**.
  - اعمل Unique Index على `(SenderId, ClientId)`.
  - لو الرسالة موجودة، رجّعها نفسها بدون ما تنشئ وحدة جديدة.
- **بعد الحفظ:** ابعتها لحظياً لـ**كل المشاركين بالمحادثة** عبر SignalR (القسم 4)، وبعدين push notification للي مش متصلين (المرحلة الجاية).

### 3.5 تعليم المحادثة كمقروءة

```
POST /api/v1/chats/{conversationId}/read
```

- **الرد:** `204`.
- **متى بيبعتها التطبيق:** لما يفتح المحادثة، وكل ما توصله رسالة من الطرف التاني وهو فاتحها.
- **المطلوب:** خزّن `LastReadAt = الآن` للمستخدم بهالمحادثة، وعليه بينحسب `unreadCount` بالقسم 3.2.

### 3.6 بلاغ طفل مفقود

```
POST /api/v1/lost-child-reports
Content-Type: multipart/form-data
```

| الحقل | النوع | ملاحظات |
|---|---|---|
| `approxAge` | int | من 1 لـ 15 |
| `description` | string | وصف الطفل وملابسه (أقصى 1000) |
| `latitude` / `longitude` | double | الموقع الحالي للمبلّغ (GPS) |
| `shareWithNearby` | `"true"` / `"false"` | مشاركة البلاغ مع المستخدمين القريبين |
| `photo` | ملف (اختياري) | jpg/png — أقصى 10MB |

**الرد:** `201` مع `{ "id": "r_77" }`.

**المطلوب من السيرفر:**

1. **احفظ البلاغ واربطه:** بمجموعة المبلّغ ومشرفها، والحالة `Open`.
2. **بلّغ المشرف فوراً:**
   - حدث SignalR `LostChildReport` لحساب المشرف.
   - Push notification (المرحلة الجاية).
3. **لو `shareWithNearby = true`:**
   - هات المستخدمين اللي آخر موقع إلهم ضمن **2 كم** من موقع البلاغ وبآخر **30 دقيقة** (بدون المبلّغ نفسه).
   - ابعتلهم إشعار فيه **العمر والوصف والصورة والموقع بس**: بدون اسم المبلّغ ولا رقمه.
   - مصدر المواقع الحيّة هو endpoint الخرائط اللي التطبيق جاهز يبعتله: `POST /api/v1/map/location`.

> ملاحظة على المنطق بالتطبيق: البلاغ بينبعت للسيرفر بس لما المعتمر يضغط «نعم , مشاركة البلاغ» (فـ `shareWithNearby` حالياً دايماً `true`). «لا , شكرا» بيلغي البلاغ بدون إرسال، حسب طلب صاحب المشروع.

---

### 3.7 بدء محادثة فردية مع شخص (من «أفراد عائلتي» ← «بدء محادثة»)

```
POST /api/v1/chats/direct
{ "userId": "9a4e…" }
```

- **الرد `200`:** نفس `ConversationSummary` تبع القائمة (3.2) للمحادثة الفردية بيني وبينه.
- **لو المحادثة موجودة** رجّعها نفسها (ما تنشئ وحدة تانية). لو مش موجودة أنشئها وضيف الاتنين عليها كـ `ConversationMember`.
- **مسموح بس** لو الشخص معي بنفس دائرة العائلة أو نفس المجموعة، وإلا `403`.

---

### 3.8 دائرة العائلة (تبويب «الأفراد»)

**الفكرة:** كل مستخدم بيكون بدائرة عائلة وحدة بالأكثر. الدائرة إلها رمز قصير (مثل `A7K9P2`) ورابط دعوة. العائلة بتنضم بالرمز أو بمسح الـ QR (محتواه `labaik://family/join?code=A7K9P2` أو رابط الدعوة نفسه)، وبعدها كل فرد بيقرر يشارك موقعه أو لا.

**المسار بالتطبيق:**

1. «الأفراد» ← «مع من تريد التتبع؟» ← «العائلة»: التطبيق بيطلب `GET /family-circle`.
   - مش بدائرة، أو أنا لحالي فيها ← «أنشئ دائرة عائلتك» (بيطلب `POST /family-circle`) ⇄ «انضم إلى دائرة عائلتك».
   - بدائرة فيها غيري و`mySharesLocation = null` ← «مشاركة موقعك مع عائلتك».
   - غير هيك ← «أفراد عائلتي».
2. شاشة الإنشاء بتسأل `GET /family-circle` كل 10 ثواني، ولما يصير `membersCount > 1` (انضم أول فرد) بتكمل لحالها.
3. «أفراد عائلتي» والخريطة بيطلبوا `GET /family-circle/members` و`GET /family-circle` كل 15 ثانية.
4. لما المستخدم يوافق على المشاركة، التطبيق بيبعت موقعه الفعلي (GPS) لـ `POST /family-circle/location` أول ما يوافق، وبعدها كل 30 ثانية أو كل ما يتحرك 50 م، والتطبيق مفتوح.

#### الـ Endpoints

| الطلب | الجسم | الرد |
|---|---|---|
| `GET /api/v1/family-circle` | — | `FamilyCircleDto`، أو **`200` مع `null`** لو مش بدائرة |
| `POST /api/v1/family-circle` | — | `FamilyCircleDto`. **لو أنا أصلاً بدائرة رجّعها نفسها** (ما تنشئ تانية). المنشئ = صاحب الدائرة |
| `GET /api/v1/family-circles/lookup?code=A7K9P2` | — | `{ "id", "name", "membersCount" }`، أو **`200` مع `null`** لو الرمز غلط (مش `404`) |
| `POST /api/v1/family-circles/{id}/join` | — | `FamilyCircleDto` بعد الانضمام. لو كنت بدائرة تانية: طلّعني منها ودخّلني بالجديدة |
| `GET /api/v1/family-circle/members` | — | `[FamilyMemberDto]` (أنا معهم، `isMe = true`) — و`[]` لو مش بدائرة |
| `PUT /api/v1/family-circle/location-sharing` | `{ "enabled": true }` | `204`. بيحفظ قراري (وبيقدر يغيّره بأي وقت من قائمة كرته) |
| `POST /api/v1/family-circle/location` | `{ "latitude", "longitude" }` | `204`. بيتجاهل الموقع لو `SharesLocation = false` |
| `DELETE /api/v1/family-circle/members/{userId}` | — | `204` — **لصاحب الدائرة بس**، وغيره `403` |

**`FamilyCircleDto`:**

```json
{
  "id": "c1…",
  "name": "عائلة أحمد",
  "code": "A7K9P2",
  "inviteLink": "https://labaik.app/family/join?code=A7K9P2",
  "isOwner": true,
  "membersCount": 4,
  "mySharesLocation": null,
  "meetingPoint": { "name": "باب الملك فهد", "latitude": 21.4232, "longitude": 39.8265 }
}
```

- **`name`:** «عائلة» + الاسم الأول لصاحب الدائرة (مثل «عائلة أحمد»).
- **`code`:** 6 أحرف/أرقام إنجليزية كبيرة **فريدة** (بدون `O/0/I/1` حتى ما تلتبس). التطبيق بيقبل من 4 لـ 12 حرف `A-Z0-9`.
- **`inviteLink`:** اختياري. لو موجود، بيروح بالـ QR وبنص الدعوة. لو `null` التطبيق بيستخدم `labaik://family/join?code=…`.
- **`mySharesLocation`:** `null` = لسا ما قررت، و`true`/`false` = قراري.
- **`meetingPoint`:** `null` لو ما في نقطة تجمع. وقتها زر «عرض نقطة التجمع» بيكتب «لم تُحدَّد نقطة تجمع بعد». تحديدها (من المشرف أو صاحب الدائرة) للمرحلة الجاية.

**`FamilyMemberDto`:**

```json
{
  "userId": "9a4e…",
  "fullName": "خالد",
  "photoUrl": "https://…/users/9a4e.jpg",
  "isMe": false,
  "isOnline": false,
  "lastSeenAt": "2026-10-15T09:23:00Z",
  "sharesLocation": true,
  "latitude": 21.4235,
  "longitude": 39.8250,
  "locationUpdatedAt": "2026-10-15T09:20:00Z"
}
```

- **`isOnline`:** `true` لو المستخدم متصل بالـ SignalR hub هلأ، أو بعت أي طلب خلال آخر دقيقتين.
- **`lastSeenAt`:** آخر نشاط. التطبيق بيكتب «اخر ظهور 18 د».
- **`latitude`/`longitude`/`locationUpdatedAt`:** بس لو `sharesLocation = true`، وغير هيك `null` (**ما تبعت موقع حدا ما وافق**).
  - التطبيق بيكتب «موقعه متاح» لو الموقع وصل خلال آخر 15 دقيقة، وإلا «موقعه غير متاح»، و«لم يشارك موقعه» لو `sharesLocation = false`.

---

## 4) SignalR — المحادثة اللحظية

- **الرابط:** `wss://labaik-api.onrender.com/hubs/chat`.
- **الاتصال:** التطبيق بيتصل **مباشرة بـ WebSocket بدون negotiate** (skipNegotiation) ومعه الهيدر `Authorization: Bearer <token>`، فالـ JwtBearer العادي بيقرأه بدون أي إعداد إضافي.
- **البروتوكول:** JSON — التطبيق بيبعت الـ handshake `{"protocol":"json","version":1}` وبعدين ping كل 15 ثانية.
- **من السيرفر للتطبيق:** حدث واحد مطلوب: **`ReceiveMessage(MessageDto)`**.
  - لازم يوصل لكل المشاركين بالمحادثة (فردية أو مجموعة) كل ما انحفظت رسالة.
  - **التطبيق بيسمعه بشاشتين:** المحادثة المفتوحة، وقائمة المحادثات (بتتحدّث آخر رسالة وعدد غير المقروء).
  - انتبه لـ `isMine`: لكل مستخدم قيمته (ابعت نسخة لكل مستخدم)، أو احذفه وخلي `senderId` موجود.
- **من التطبيق للسيرفر:** ولا method. الإرسال بيصير عن طريق REST (القسم 3.4).
- **⚠️ مهم:** الرسالة الترحيبية «أهلاً بك، لنتمكن من مساعدتك…» بمحادثة المشرف من مركز المساعدة **التطبيق بيعرضها لحاله**. السيرفر **ما** لازم يضيفها كرسالة.

### كود مقترح

```csharp
// Program.cs
builder.Services.AddSignalR();
builder.Services.AddSingleton<IUserIdProvider, SubUserIdProvider>();
// (اختياري لعملاء الويب: قراءة access_token من الـ query)
builder.Services.Configure<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme, o =>
{
    o.Events ??= new JwtBearerEvents();
    o.Events.OnMessageReceived = ctx =>
    {
        var token = ctx.Request.Query["access_token"];
        if (!string.IsNullOrEmpty(token) && ctx.HttpContext.Request.Path.StartsWithSegments("/hubs")) ctx.Token = token;
        return Task.CompletedTask;
    };
});
// ...
app.MapHub<ChatHub>("/hubs/chat");
```

```csharp
[Authorize]
public class ChatHub : Hub { } // السيرفر بس بيبعت — التطبيق ما بينادي أي method

public class SubUserIdProvider : IUserIdProvider
{
    public string? GetUserId(HubConnectionContext c) =>
        c.User?.FindFirst("sub")?.Value ?? c.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;
}
```

```csharp
[Authorize, ApiController, Route("api/v1/chats")]
public class ChatsController(AppDb db, IHubContext<ChatHub> hub) : ControllerBase
{
    [HttpPost("{conversationId}/messages")]
    public async Task<ActionResult<MessageDto>> Send(Guid conversationId, SendMessageRequest req)
    {
        var me = User.UserId();                                    // من الـ JWT
        var members = await db.ConversationMembers.Where(m => m.ConversationId == conversationId).Select(m => m.UserId).ToListAsync();
        if (members.Count == 0) return NotFound();
        if (!members.Contains(me)) return Forbid();
        if (string.IsNullOrWhiteSpace(req.Text) && (req.Latitude is null || req.Longitude is null)) return BadRequest();

        // نفس clientId من نفس المرسل = نفس الرسالة (إعادة محاولة)
        var existing = await db.Messages.FirstOrDefaultAsync(m => m.SenderId == me && m.ClientId == req.ClientId);
        if (existing is not null) return Ok(await MessageDto.From(db, existing, me));

        var msg = new Message
        {
            ConversationId = conversationId, SenderId = me, ClientId = req.ClientId,
            Text = req.Text?.Trim(), Latitude = req.Latitude, Longitude = req.Longitude, SentAt = DateTime.UtcNow,
        };
        db.Messages.Add(msg);
        await db.SaveChangesAsync();

        // لحظياً لكل المشاركين — كل واحد بقيمة isMine تبعه
        foreach (var user in members)
            await hub.Clients.User(user.ToString()).SendAsync("ReceiveMessage", await MessageDto.From(db, msg, user));
        return StatusCode(201, await MessageDto.From(db, msg, me));
    }

    [HttpPost("{conversationId}/read")]
    public async Task<IActionResult> Read(Guid conversationId)
    {
        var member = await db.ConversationMembers.FindAsync(conversationId, User.UserId());
        if (member is null) return Forbid();
        member.LastReadAt = DateTime.UtcNow;
        await db.SaveChangesAsync();
        return NoContent();
    }
}
```

---

## 5) الجداول (EF Core)

```csharp
public class Group        { public Guid Id; public string Name; public string? PhotoUrl; public Guid CompanyId; public Guid SupervisorId; }
public class GroupMember  { public Guid GroupId; public Guid PilgrimId; }                       // PK (GroupId, PilgrimId)
// المستخدم (معتمر أو مشرف) — ضيف له: PhoneNumber, PhotoUrl

public class Conversation
{
    public Guid Id; public bool IsGroup; public Guid? GroupId;   // مجموعة الحملة: GroupId — الفردية: null
    public DateTime CreatedAt;
}
public class ConversationMember
{
    public Guid ConversationId; public Guid UserId;              // PK (ConversationId, UserId)
    public bool IsPinned;                                        // المشرف ومجموعة الحملة مثبّتين للمعتمر
    public DateTime? LastReadAt;                                 // unreadCount = رسائل غيره بعد هالوقت
}
public class Message
{
    public Guid Id; public Guid ConversationId; public Guid SenderId;
    public string ClientId;                 // Unique (SenderId, ClientId)
    public string? Text; public double? Latitude; public double? Longitude;
    public DateTime SentAt;
}                                           // Index (ConversationId, SentAt)

public class LostChildReport
{
    public Guid Id; public Guid ReporterId; public Guid? GroupId; public Guid? SupervisorId;
    public int ApproxAge; public string Description; public double Latitude; public double Longitude;
    public string? PhotoUrl; public bool ShareWithNearby; public string Status = "Open"; public DateTime CreatedAt;
}

public class FamilyCircle
{
    public Guid Id; public string Name; public string Code;      // Unique (Code)
    public Guid OwnerId; public DateTime CreatedAt;
    public string? MeetingPointName; public double? MeetingLatitude; public double? MeetingLongitude;
}
public class FamilyCircleMember
{
    public Guid CircleId; public Guid UserId;                    // PK (CircleId, UserId) — و Unique (UserId): دائرة وحدة لكل مستخدم
    public bool IsOwner; public bool? SharesLocation;            // null = لسا ما قرر
    public double? LastLatitude; public double? LastLongitude; public DateTime? LocationUpdatedAt;
    public DateTime JoinedAt;
}
// المستخدم — ضيف له: LastSeenAt (بيتحدّث مع كل طلب أو اتصال بالـ hub)

public class UserLocation { public Guid UserId; public double Latitude; public double Longitude; public DateTime UpdatedAt; } // من /map/location
public class DeviceToken  { public Guid UserId; public string Token; public string Platform; public DateTime UpdatedAt; }  // للمرحلة الجاية (FCM)
```

- **`MessageDto.From(db, msg, viewerId)`:** بيعبّي `isMine = msg.SenderId == viewerId`، واسم المرسل وصورته من جدول المستخدمين.
- **دائرة العائلة:**
  - لما صاحب الدائرة يطلع منها أو ينحذف حسابه، انقل الملكية لأقدم فرد (أو احذف الدائرة لو فاضية).
  - `membersCount` = عدد صفوف `FamilyCircleMember` للدائرة.
- **لما ينضاف معتمر لمجموعة:**
  1. ضيفه على محادثة المجموعة.
  2. أنشئ محادثته الفردية مع المشرف.
  3. خلي الاتنين `IsPinned = true`.

---

## 6) المرحلة الجاية (التطبيق لسا ما بيستخدمها)

| Endpoint | الرد |
|---|---|
| `GET /api/v1/lost-child-reports?status=Open` | بلاغات مجموعات المشرف |
| `PATCH /api/v1/lost-child-reports/{id}` | `{ "status": "Found" }` |
| `POST /api/v1/devices` | `{ "token": "<FCM>", "platform": "android" }` |

شاشات المشرف للمحادثات بتستخدم نفس `GET /api/v1/chats` ونفس الرسائل (القسم 3).

---

## 7) تجربة سريعة

```bash
# المشرف
curl -H "Authorization: Bearer $TOKEN" https://labaik-api.onrender.com/api/v1/pilgrim/supervisor

# قائمة المحادثات
curl -H "Authorization: Bearer $TOKEN" https://labaik-api.onrender.com/api/v1/chats

# إرسال رسالة (مرتين بنفس clientId → لازم ترجع نفس الرسالة)
curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"clientId":"test-1","text":"مرحبا"}' \
  https://labaik-api.onrender.com/api/v1/chats/$CONV/messages

# مقروءة
curl -X POST -H "Authorization: Bearer $TOKEN" https://labaik-api.onrender.com/api/v1/chats/$CONV/read

# دائرة العائلة: إنشاء (أو دائرتي) ← البحث بالرمز من حساب تاني ← الانضمام ← الأفراد
curl -X POST -H "Authorization: Bearer $TOKEN" https://labaik-api.onrender.com/api/v1/family-circle
curl -H "Authorization: Bearer $TOKEN2" "https://labaik-api.onrender.com/api/v1/family-circles/lookup?code=A7K9P2"
curl -X POST -H "Authorization: Bearer $TOKEN2" https://labaik-api.onrender.com/api/v1/family-circles/$CIRCLE/join
curl -X PUT -H "Authorization: Bearer $TOKEN2" -H "Content-Type: application/json" -d '{"enabled":true}' \
  https://labaik-api.onrender.com/api/v1/family-circle/location-sharing
curl -H "Authorization: Bearer $TOKEN" https://labaik-api.onrender.com/api/v1/family-circle/members

# بلاغ
curl -X POST -H "Authorization: Bearer $TOKEN" \
  -F approxAge=7 -F "description=قميص أحمر" -F latitude=21.4225 -F longitude=39.8262 \
  -F shareWithNearby=true -F photo=@child.jpg \
  https://labaik-api.onrender.com/api/v1/lost-child-reports
```

- **شغّال صح:** لما تفتح حسابين، معتمر ومشرفه، وترسل من المعتمر، لازم الرسالة تطلع عند المشرف بأقل من ثانية (SignalR).
  - قائمة محادثات المشرف بتزيد عدد غير المقروء.
- **لو SignalR مش شغّال:**
  - الرسالة بتطلع خلال 4 ثواني (التحديث الدوري).
  - القائمة بتتحدّث كل 15 ثانية.
