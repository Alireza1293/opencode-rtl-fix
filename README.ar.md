# إصلاح RTL لـ OpenCode على macOS

هذا تصحيح محلي غير رسمي لتطبيق OpenCode Desktop على macOS. يحسن عرض النصوص العربية والفارسية في المحادثة وMarkdown والاقتباسات وكتل الكود التي تحتوي على نص RTL.

كما يتم استبدال النص العربي والفارسي بخط أكثر وضوحا.

## الثقة ونطاق التأثير

This project does not collect data, does not send analytics, and does not modify user projects. It only patches the installed OpenCode Desktop app.asar file and creates a local backup.

OpenCode is a separate project and is not affiliated with this repository. This license only applies to the patch scripts and files in this repository.

هذا المشروع لا يجمع البيانات، ولا يرسل أي analytics، ولا يغير مشاريع المستخدم. يقوم فقط بتعديل ملف `app.asar` المثبت الخاص بتطبيق OpenCode Desktop وينشئ نسخة احتياطية محلية.

OpenCode مشروع منفصل ولا يرتبط بهذا المستودع. ينطبق الترخيص هنا فقط على سكربتات وملفات التصحيح الموجودة في هذا المستودع.

## المتطلبات

- macOS
- تثبيت OpenCode Desktop في المسار `/Applications/OpenCode.app`
- توفر Node.js وأوامر `node` و `npx`
- اتصال بالإنترنت في أول تشغيل، لأن السكربت يستخدم `npx @electron/asar`

## التثبيت

قم بتنزيل أحدث ملف ZIP من Releases ثم فك الضغط، وبعدها انقر مرتين على:

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

بعد تطبيق التصحيح، أغلق OpenCode بالكامل ثم افتحه من جديد.

## الاستعادة

للرجوع إلى النسخة الأصلية، انقر مرتين على:

```text
unpatch.command
```

أو شغل:

```bash
./unpatch.command
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

## ملاحظات

- هذا التصحيح يعدل ملف `app.asar` داخل نسخة OpenCode Desktop المثبتة.
- قد تؤدي تحديثات OpenCode إلى إزالة التصحيح. شغل `patch.command` مرة أخرى بعد التحديث.
- هذا تصحيح غير رسمي ولا يتبع فريق OpenCode.
