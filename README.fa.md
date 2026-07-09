# اصلاح RTL اوپن‌کد برای macOS

این یک پچ محلی و غیررسمی برای نسخه Desktop اوپن‌کد روی macOS است. این پچ نمایش متن‌های فارسی و عربی را در چت، Markdown، نقل‌قول‌ها و code blockهایی که متن RTL دارند بهتر می‌کند.

همچنین متن فارسی و عربی با یک فونت خواناتر جایگزین می‌شود.

## اعتماد و محدوده اثر

This project does not collect data, does not send analytics, and does not modify user projects. It only patches the installed OpenCode Desktop app.asar file and creates a local backup.

OpenCode is a separate project and is not affiliated with this repository. This license only applies to the patch scripts and files in this repository.

این پروژه هیچ داده‌ای جمع‌آوری نمی‌کند، analytics ارسال نمی‌کند و پروژه‌های کاربر را تغییر نمی‌دهد. فقط فایل نصب‌شده `app.asar` مربوط به OpenCode Desktop را patch می‌کند و یک backup محلی می‌سازد.

OpenCode یک پروژه جداگانه است و این ریپو وابسته به آن نیست. لایسنس این ریپو فقط شامل اسکریپت‌ها و فایل‌های پچ داخل همین ریپو می‌شود.

## پیش‌نیازها

- macOS
- نصب بودن OpenCode Desktop در مسیر `/Applications/OpenCode.app`
- نصب بودن Node.js و در دسترس بودن دستور `node` و `npx`
- دسترسی اینترنت برای اجرای اول، چون اسکریپت از `npx @electron/asar` استفاده می‌کند

## نصب

آخرین فایل ZIP را از بخش Releases دانلود و extract کنید، سپس روی این فایل دوبار کلیک کنید:

```text
patch.command
```

یا از Terminal اجرا کنید:

```bash
./patch.command
```

اگر OpenCode در مسیر دیگری نصب شده است:

```bash
OPENCODE_APP="/path/to/OpenCode.app" ./patch.command
```

بعد از اجرای پچ، OpenCode را کامل ببندید و دوباره باز کنید.

## بازگردانی

برای برگشت به نسخه اصلی، روی این فایل دوبار کلیک کنید:

```text
unpatch.command
```

یا اجرا کنید:

```bash
./unpatch.command
```

قبل از تغییر، پچ کنار فایل `app.asar` یک backup می‌سازد.

## تست

در OpenCode این پیام را بفرستید:

```text
سلام، این یک تست فارسی است.
```

نتیجه مورد انتظار:

- متن فارسی و عربی راست‌چین و راست‌به‌چپ نمایش داده شود.
- نقطه و علائم نگارشی در جای درست جمله دیده شوند.
- متن انگلیسی، مسیر فایل‌ها و کدهای عادی چپ‌به‌راست باقی بمانند.

## نکات

- این پچ فایل `app.asar` نسخه نصب‌شده OpenCode Desktop را تغییر می‌دهد.
- آپدیت OpenCode ممکن است پچ را حذف کند. بعد از آپدیت دوباره `patch.command` را اجرا کنید.
- این پچ غیررسمی است و وابسته به تیم OpenCode نیست.
