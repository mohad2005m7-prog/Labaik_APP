# تعديلات جاهزة لباك إند إبراهيم (im-tayeh/Labaik)

نسخة احتياطية من تعديلات الباك لحد ما ينفتح الـ Pull Request (بدها Fork من حساب محمد).

| الملف | الوصف |
|---|---|
| `0001-company-supervisor-control.patch` | التحكم بالمشرفين من الشركة: حذف (409 لو بيشرف على مجموعة) / إيقاف وتفعيل (المشرف الموقوف ما بيدخل) / كلمة مرور مؤقتة جديدة — migration `AddSupervisorSuspension` + اختبارات (154 ناجحة) |

## تطبيقه يدوياً (لو احتجت)
```
git clone https://github.com/im-tayeh/Labaik
cd Labaik
git checkout -b feat/company-supervisor-control
git am path/to/0001-company-supervisor-control.patch
```
