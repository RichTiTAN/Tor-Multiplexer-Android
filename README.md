# Tor Multiplexer for Android
An android tool that runs 4 tor connections and load balances them with HAProxy.  

Why?  

- Tor but faster.


How to use:  

1. Install the dependencies:

  - Termux: https://github.com/termux/termux-app/releases/tag/v0.118.3
  
  - Termux Widget: https://github.com/termux/termux-widget/releases/tag/v0.15.0

    
2. Now run Termux and copy one of the codes below to start the installation based on the bridge type you want to use in tor:

*   **Meek:**
  
 ```bash
 curl -sL [https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-meek.sh](https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-meek.sh) | bash
```
    
*   **Obfs4:**
  
```bash
curl -sL [https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-obfs4.sh](https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-obfs4.sh) | bash
```

*   **Snowflake:**
  
```bash
curl -sL [https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-snowflake.sh](https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-snowflake.sh) | bash
```

*   **Direct (No Bridge):**
  
```bash
curl -sL [https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-direct.sh](https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-direct.sh) | bash
```

Note: if you have problem connecting to the repositories you can run this command and try again:  
```
echo 'Acquire::http::Timeout "120";' > $PREFIX/etc/apt/apt.conf.d/99timeout  
echo 'Acquire::ftp::Timeout "120";' >> $PREFIX/etc/apt/apt.conf.d/99timeout
```


3. The installation will ask if you have an outbound proxy that you want to set up, if you do enter it in this format:
   ip:port (example: 127.0.0.1:10880)


4. After the installation is finished, Go to your home screen, create a widget using Termux Widget, create a 1x1 widget, the first time choose start.sh (this will launch tor and HAProxy)
Repeat the shortcut creation process, this time choose tasks/ then kill_switch.sh (this will close all the tor connections and HAProxy)


5. Now you can run Tor Multiplexer using start.sh on your home screen
After the process is finished the app will create a socks proxy with this address and port: 127.0.0.1:10888

(IMPORTANT NOTE: the app will close after it runs everything but it's running in the background, you'll be able to close it with the kill_switch.sh shortcut you created.)


6. You can create a Socks profile in any proxy app (v2rayNG for example) and use that address and port to connect to the internet. MAKE SURE YOU ALLOW Termux AND ANY OTHER APP YOU MIGHT BE USING FOR THIS SETUP TO BYPASS YOUR VPN APP.


Note: The initial start-up might take up to 30minutes, be patient, the next launches will be faster.


نحوه استفاده:

۱. نصب نیازمندی‌ها:

Termux: https://github.com/termux/termux-app/releases/tag/v0.118.3

Termux Widget: https://github.com/termux/termux-widget/releases/tag/v0.15.0

۲. ابتدا نرم افزار termux را اجرا کنید و با کپی کردن یکی از لینک های زیر بر اساس نوع Bridge نصب را شروع کنید:

Meek:

```Bash
curl -sL https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-meek.sh | bash
```
Obfs4:

```Bash
curl -sL https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-obfs4.sh | bash
```
Snowflake:

```Bash
curl -sL https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-snowflake.sh | bash
```
Direct (بدون Bridge):

```Bash
curl -sL https://raw.githubusercontent.com/RichTiTAN/Tor-Multiplexer-Android/main/setup-direct.sh | bash
```
نکته: اگر در اتصال به مخازن (Repositories) مشکل دارید، این دستور را اجرا کنید و دوباره تلاش کنید:

```Bash
echo 'Acquire::http::Timeout "120";' > $PREFIX/etc/apt/apt.conf.d/99timeout
echo 'Acquire::ftp::Timeout "120";' >> $PREFIX/etc/apt/apt.conf.d/99timeout
```
۳. در طول نصب از شما پرسیده می‌شود که آیا می‌خواهید یک Outbound Proxy تنظیم کنید؛ اگر دارید، آن را با این فرمت وارد کنید:

ip:port (مانند: 127.0.0.1:10880)

۴. پس از اتمام نصب، به صفحه اصلی گوشی (Home Screen) بروید و با استفاده از Termux Widget یک ویجت ۱x۱ بسازید. برای اولین بار فایل start.sh را انتخاب کنید (این کار باعث اجرای Tor و HAProxy می‌شود).

سپس همین مراحل را تکرار کنید و این بار از پوشه tasks/ فایل kill_switch.sh را انتخاب کنید (این کار تمام اتصالات Tor و HAProxy را می‌بندد).

۵. حالا می‌توانید با استفاده از میانبر start.sh در صفحه اصلی، Tor Multiplexer را اجرا کنید.

پس از اتمام فرآیند، برنامه یک Socks Proxy با این آدرس و پورت ایجاد می‌کند: 127.0.0.1:10888

نکته مهم: برنامه پس از اجرای همه‌چیز بسته می‌شود اما در پس‌زمینه در حال اجرا باقی می‌ماند. شما می‌توانید آن را با میانبر kill_switch.sh که ساختید، متوقف کنید.

۶. می‌توانید در هر برنامه پروکسی (برای مثال v2rayNG) یک پروفایل Socks بسازید و از آن آدرس و پورت برای اتصال به اینترنت استفاده کنید. مطمئن شوید که در تنظیمات VPN، برنامه‌ Termux و هر برنامه دیگری که در این پروسه استفاده می‌شود را در حالت Bypass قرار دهید تا تداخلی ایجاد نشود.

نکته: اولین راه‌اندازی ممکن است تا ۳۰ دقیقه طول بکشد، صبور باشید. دفعات بعدی بسیار سریع‌تر خواهد بود.
