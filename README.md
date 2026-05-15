# Tor Multiplexer for Android
An android tool that runs 4 tor connections and load balances them with HAProxy.  

Why?  

- Tor but faster.


How to use:  

1. Install the dependencies:

  - Termux: https://github.com/termux/termux-app/releases/tag/v0.118.3
  
  - Termux Widget: https://github.com/termux/termux-widget/releases/tag/v0.15.0

    
2. Start the installation based on the bridge type you want to use in tor:

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

Note: if you have problem connecting to the repositories you can run this command:  
echo 'Acquire::http::Timeout "120";' > $PREFIX/etc/apt/apt.conf.d/99timeout  

echo 'Acquire::ftp::Timeout "120";' >> $PREFIX/etc/apt/apt.conf.d/99timeout


3. The installation will ask if you have an outbound proxy that you want to set up, if you do enter it in this format:
   ip:port example: 127.0.0.1:10880


4. After the installation is finished, Go to your home screen, create a widget using Termux Widget, create a 1x1 widget, the first time choose start.sh (this will launch tor and HAProxy)
Repeat the shortcut creation process, this time choose tasks/ then kill_switch.sh (this will close all the tor connections and HAProxy)


5. Now you can run Tor Multiplexer using start.sh on your home screen
After the process is finished the app will create a socks proxy with this address and port: 127.0.0.1:10888

(IMPORTANT NOTE: the app will close after it runs everything but it's running in the background, you'll be able to close it with the kill_switch.sh shortcut you created.


6. You can create a Socks profile in any proxy app (v2rayNG for example) and use that address and port to connect to the internet. MAKE SURE YOU ALLOW Termux AND ANY OTHER APP YOU MIGHT BE USING FOR THIS SETUP TO BYPASS YOUR VPN APP.


Note: The initial start-up might take up to 30minutes, be patient, the next launches will be faster.
