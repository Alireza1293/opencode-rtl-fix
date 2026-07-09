# اصلاح RTL اوپن‌کد

این یک پچ محلی و غیررسمی برای نسخه Desktop اوپن‌کد روی macOS و Windows است. این پچ نمایش متن‌های فارسی و عربی را در چت، Markdown، نقل‌قول‌ها و code blockهایی که متن RTL دارند بهتر می‌کند.

همچنین متن فارسی و عربی با یک فونت خواناتر جایگزین می‌شود.

## اعتماد و محدوده اثر

این پروژه هیچ داده‌ای جمع‌آوری نمی‌کند، analytics ارسال نمی‌کند و پروژه‌های کاربر را تغییر نمی‌دهد. فقط فایل نصب‌شده `app.asar` مربوط به OpenCode Desktop را patch می‌کند و یک backup محلی می‌سازد.

OpenCode یک پروژه جداگانه است و این ریپو وابسته به آن نیست. لایسنس این ریپو فقط شامل اسکریپت‌ها و فایل‌های پچ داخل همین ریپو می‌شود.

## پیش‌نیازها

- macOS یا Windows
- نصب بودن OpenCode Desktop
- نصب بودن Node.js و در دسترس بودن دستور `node` و `npx`
- دسترسی اینترنت برای اجرای اول، چون اسکریپت از `npx @electron/asar` استفاده می‌کند

## نصب

آخرین فایل ZIP را از بخش Releases دانلود و extract کنید.

### macOS

روی این فایل دوبار کلیک کنید:

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

### Windows

PowerShell را باز کنید و اجرا کنید:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\patch.ps1
```

اگر OpenCode در مسیر دیگری نصب شده است:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\patch.ps1 -AsarPath "C:\Path\To\OpenCode\resources\app.asar"
```

می‌توانید به جای مسیر دقیق `app.asar`، مسیر پوشه نصب OpenCode را هم بدهید.

بعد از اجرای پچ، OpenCode را کامل ببندید و دوباره باز کنید.

## بازگردانی

### macOS

برای برگشت به نسخه اصلی، روی این فایل دوبار کلیک کنید:

```text
unpatch.command
```

یا اجرا کنید:

```bash
./unpatch.command
```

### Windows

اجرا کنید:

```powershell
powershell -ExecutionPolicy Bypass -File .\windows\unpatch.ps1
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

## حمایت از پروژه

اگر این پچ برای شما مفید بود، می‌توانید با یک کمک کوچک کریپتویی از پروژه حمایت کنید.

USDT (TRC20): `TF2SffSgmxF2bybzLZMDRZYnmuG6HwywQZ`

USDC (Base): `0xBab66d7b78099Fb3A53e5556236358612d7a150c`

GRAM (TON Network): `UQDr6SiRznhjlngE-NQ0aLoNLTb_gsV0KENakOYJ-CUVJKUy`

## نکات

- این پچ فایل `app.asar` نسخه نصب‌شده OpenCode Desktop را تغییر می‌دهد.
- آپدیت OpenCode ممکن است پچ را حذف کند. بعد از آپدیت دوباره پچ را اجرا کنید.
- این پچ غیررسمی است و وابسته به تیم OpenCode نیست.
