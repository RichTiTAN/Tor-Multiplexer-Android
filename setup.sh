#!/bin/bash

# --- 1. PREPARE TERMINAL ---
clear
echo "=========================================="
echo "    TOR MULTIPLEXER: ANDROID INSTALLER"
echo "=========================================="

# --- 2. BRIDGE SELECTION ---
echo "Choose your Bridge Type:"
echo "1) obfs4 (Recommended)"
echo "2) meek_lite (Azure/CDN)"
echo "3) snowflake"
echo "4) None (Direct Connect)"
echo "=========================================="
read -p "Selection [1-4]: " B_CHOICE

# Define the exact text block for each choice safely
if [ "$B_CHOICE" == "1" ]; then
BRIDGE_BLOCK="UseBridges 1
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D cert=bjRaMrr1BRiAW8IE9U5z27fQaYgOhX1UCmOpg2pFpoMvo6ZgQMzLsaTzzQNTlm7hNcb+Sg iat-mode=0
Bridge obfs4 209.148.46.65:443 74FAD13168806246602538555B5521A0383A1875 cert=ssH+9rP8dG2NLDN2XuFw63hIO/9MNNinLmxQDpVa+7kTOa9/m+tGWT1SmSYpQ9uTBGa6Hw iat-mode=0
Bridge obfs4 146.57.248.225:22 10A6CD36A537FCE513A322361547444B393989F0 cert=K1gDtDAIcUfeLqbstggjIw2rtgIKqdIhUlHp82XRqNSq/mtAjp1BIC9vHKJ2FAEpGssTPw iat-mode=0
Bridge obfs4 45.145.95.6:27015 C5B7CD6946FF10C5B3E89691A7D3F2C122D2117C cert=TD7PbUO0/0k6xYHMPW3vJxICfkMZNdkRrb63Zhl5j9dW3iRGiCx0A7mPhe5T2EDzQ35+Zw iat-mode=0
Bridge obfs4 51.222.13.177:80 5EDAC3B810E12B01F6FD8050D2FD3E277B289A08 cert=2uplIpLQ0q9+0qMFrK5pkaYRDOe460LL9WHBvatgkuRr/SL31wBOEupaMMJ6koRE6Ld0ew iat-mode=0
Bridge obfs4 212.83.43.95:443 BFE712113A72899AD685764B211FACD30FF52C31 cert=ayq0XzCwhpdysn5o0EyDUbmSOx3X/oTEbzDMvczHOdBJKlvIdHHLJGkZARtT4dcBFArPPg iat-mode=1
Bridge obfs4 212.83.43.74:443 39562501228A4D5E27FCA4C0C81A01EE23AE3EE4 cert=PBwr+S8JTVZo6MPdHnkTwXJPILWADLqfMGoVvhZClMq/Urndyd42BwX9YFJHZnBB3H0XCw iat-mode=1"

elif [ "$B_CHOICE" == "2" ]; then
BRIDGE_BLOCK="UseBridges 1
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge meek_lite 192.0.2.20:80 url=https://1603026938.rsc.cdn77.org front=www.phpmyadmin.net utls=HelloRandomizedALPN"

elif [ "$B_CHOICE" == "3" ]; then
BRIDGE_BLOCK="UseBridges 1
ClientTransportPlugin snowflake exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org/ fronts=app.datapacket.com,www.datapacket.com ice=stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.telnyx.com:3478,stun:stun.hot-chilli.net:3478,stun:stun.fitauto.ru:3478,stun:stun.m-online.net:3478 utls-imitate=hellorandomizedalpn
Bridge snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=app.datapacket.com,www.datapacket.com ice=stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.telnyx.com:3478,stun:stun.hot-chilli.net:3478,stun:stun.fitauto.ru:3478,stun:stun.m-online.net:3478 utls-imitate=hellorandomizedalpn"

else
BRIDGE_BLOCK="UseBridges 0"
fi

# --- 3. PROXY CONFIG ---
echo ""
read -p "Enter Outbound Proxy (format IP:PORT). Leave blank to skip: " PROXY_IN
if [ -n "$PROXY_IN" ]; then
PROXY_LINE="Socks5Proxy $PROXY_IN"
else
PROXY_LINE=""
fi

# --- 4. INSTALL DEPENDENCIES ---
echo ""
echo "Updating packages and installing Tor/HAProxy..."
pkg update -y && pkg install -y tor lyrebird haproxy

# --- 5. CREATE DIRECTORIES ---
mkdir -p ~/.shortcuts/tasks
mkdir -p ~/multiplexer

# --- 6. GENERATE THE PERMANENT START WIDGET ---
cat << EOF > ~/.shortcuts/start.sh
#!/bin/bash
pkill tor
pkill haproxy
termux-wake-lock

cd ~/multiplexer

# Generate HAProxy Config
cat << 'HAP' > haproxy.cfg
defaults
    mode tcp
    timeout connect 5s
    timeout client 1h
    timeout server 1h

frontend tor_front
    bind 127.0.0.1:10888
    default_backend tor_back

backend tor_back
    balance leastconn
    server tor1 127.0.0.1:9061 check
    server tor2 127.0.0.1:9062 check
    server tor3 127.0.0.1:9063 check
    server tor4 127.0.0.1:9064 check
HAP

# Generate and launch 4 Tor Engines
for i in {1..4}; do
    PORT=\$((9060 + i))
    DIR="tor_data_\$i"
    mkdir -p \$DIR

    cat << TORCFG > torrc\$i
SocksPort \$PORT
DataDirectory \$DIR
$BRIDGE_BLOCK
$PROXY_LINE
TORCFG

    echo "Launching Tor instance \$i..."
    tor -f torrc\$i &
    [ \$i -lt 4 ] && sleep 8
done

haproxy -f haproxy.cfg &
echo "=========================================="
echo " MULTIPLEXER ONLINE: 127.0.0.1:10888"
echo "=========================================="
EOF

# --- 7. GENERATE KILL SWITCH ---
cat << 'EOF' > ~/.shortcuts/tasks/kill_switch.sh
#!/bin/bash
pkill tor
pkill haproxy
termux-wake-unlock
echo "Stopped."
EOF

# --- 8. FINAL PERMISSIONS ---
chmod +x ~/.shortcuts/start.sh
chmod +x ~/.shortcuts/tasks/kill_switch.sh

echo ""
echo "✅ Setup Finished!"
echo "Nothing is running yet. Use your Home Screen widgets to start/stop."
