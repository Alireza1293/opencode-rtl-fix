# إصلاح RTL لـ OpenCode

هذا تصحيح محلي غير رسمي لتطبيق OpenCode Desktop على macOS و Windows. يحسن عرض النصوص العربية والفارسية في المحادثة وMarkdown والاقتباسات وكتل الكود التي تحتوي على نص RTL.

كما يتم استبدال النص العربي والفارسي بخط أكثر وضوحا.

## الثقة ونطاق التأثير

هذا المشروع لا يجمع البيانات، ولا يرسل أي analytics، ولا يغير مشاريع المستخدم. يقوم فقط بتعديل ملف `app.asar` المثبت الخاص بتطبيق OpenCode Desktop وينشئ نسخة احتياطية محلية.

OpenCode مشروع منفصل ولا يرتبط بهذا المستودع. ينطبق الترخيص هنا فقط على سكربتات وملفات التصحيح الموجودة في هذا المستودع.

## المتطلبات

- macOS أو Windows
- تثبيت OpenCode Desktop
- توفر Node.js وأوامر `node` و `npx`
- اتصال بالإنترنت في أول تشغيل، لأن السكربت يستخدم `npx @electron/asar`

## التثبيت

قم بتنزيل أحدث ملف ZIP من Releases ثم فك الضغط.

### macOS

انقر مرتين على:

```text
patch.command
```

أو شغله من Terminal:

```bash
./patch.command
```

إذا كان OpenCode مثبتا في مسار آخر:

```bash
OPENCODE_APP="/path/to/OpenCode.app" ./patch.command
```

### Windows

افتح PowerShell ثم شغل:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\patch.ps1
```

إذا كان OpenCode مثبتا في مسار آخر:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\patch.ps1 -AsarPath "C:\Path\To\OpenCode\resources\app.asar"
```

يمكنك أيضا تمرير مجلد تثبيت OpenCode بدلا من مسار `app.asar` الكامل.

بعد تطبيق التصحيح، أغلق OpenCode بالكامل ثم افتحه من جديد.

## الاستعادة

### macOS

للرجوع إلى النسخة الأصلية، انقر مرتين على:

```text
unpatch.command
```

أو شغل:

```bash
./unpatch.command
```

### Windows

شغل:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\unpatch.ps1
```

ينشئ التصحيح نسخة احتياطية بجانب ملف `app.asar` قبل تعديله.

## الاختبار

أرسل هذه الرسالة في OpenCode:

```text
مرحبا، هذا اختبار عربي.
```

النتيجة المتوقعة:

- تظهر النصوص العربية والفارسية بمحاذاة اليمين وباتجاه RTL.
- تظهر علامات الترقيم في الموضع الصحيح من الجملة.
- تبقى النصوص الإنجليزية ومسارات الملفات والكود العادي باتجاه LTR.

## دعم المشروع

إذا ساعدك هذا التصحيح، يمكنك دعم المشروع بتبرع صغير عبر العملات الرقمية.

USDT (TRC20): `TF2SffSgmxF2bybzLZMDRZYnmuG6HwywQZ`

USDC (Base): `0xBab66d7b78099Fb3A53e5556236358612d7a150c`

GRAM (TON Network): `UQDr6SiRznhjlngE-NQ0aLoNLTb_gsV0KENakOYJ-CUVJKUy`

## ملاحظات

- هذا التصحيح يعدل ملف `app.asar` داخل نسخة OpenCode Desktop المثبتة.
- قد تؤدي تحديثات OpenCode إلى إزالة التصحيح. شغل التصحيح مرة أخرى بعد التحديث.
- هذا تصحيح غير رسمي ولا يتبع فريق OpenCode.
