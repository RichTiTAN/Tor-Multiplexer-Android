#!/bin/bash
clear
echo "Installing Tor Multiplexer (Bridge: OBFS4)..."
read -p "Enter Outbound Proxy (IP:PORT) or leave blank: " PROXY_IN </dev/tty

pkg update -y && pkg install -y tor lyrebird haproxy
mkdir -p ~/.shortcuts/tasks ~/multiplexer

cat << 'EOF' > ~/multiplexer/bridge.conf
UseBridges 1
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge obfs4 37.218.245.14:38224 D9A82D2F9C2F65A18407B1D2B764F130847F8B5D cert=bjRaMrr1BRiAW8IE9U5z27fQaYgOhX1UCmOpg2pFpoMvo6ZgQMzLsaTzzQNTlm7hNcb+Sg iat-mode=0
Bridge obfs4 209.148.46.65:443 74FAD13168806246602538555B5521A0383A1875 cert=ssH+9rP8dG2NLDN2XuFw63hIO/9MNNinLmxQDpVa+7kTOa9/m+tGWT1SmSYpQ9uTBGa6Hw iat-mode=0
Bridge obfs4 146.57.248.225:22 10A6CD36A537FCE513A322361547444B393989F0 cert=K1gDtDAIcUfeLqbstggjIw2rtgIKqdIhUlHp82XRqNSq/mtAjp1BIC9vHKJ2FAEpGssTPw iat-mode=0
Bridge obfs4 45.145.95.6:27015 C5B7CD6946FF10C5B3E89691A7D3F2C122D2117C cert=TD7PbUO0/0k6xYHMPW3vJxICfkMZNdkRrb63Zhl5j9dW3iRGiCx0A7mPhe5T2EDzQ35+Zw iat-mode=0
Bridge obfs4 51.222.13.177:80 5EDAC3B810E12B01F6FD8050D2FD3E277B289A08 cert=2uplIpLQ0q9+0qMFrK5pkaYRDOe460LL9WHBvatgkuRr/SL31wBOEupaMMJ6koRE6Ld0ew iat-mode=0
Bridge obfs4 212.83.43.95:443 BFE712113A72899AD685764B211FACD30FF52C31 cert=ayq0XzCwhpdysn5o0EyDUbmSOx3X/oTEbzDMvczHOdBJKlvIdHHLJGkZARtT4dcBFArPPg iat-mode=1
Bridge obfs4 212.83.43.74:443 39562501228A4D5E27FCA4C0C81A01EE23AE3EE4 cert=PBwr+S8JTVZo6MPdHnkTwXJPILWADLqfMGoVvhZClMq/Urndyd42BwX9YFJHZnBB3H0XCw iat-mode=1
EOF

[ -n "$PROXY_IN" ] && echo "Socks5Proxy $PROXY_IN" > ~/multiplexer/proxy.conf || echo "" > ~/multiplexer/proxy.conf

# (Start/Kill Widget generation code below)
# --- GENERATE START WIDGET ---
cat << 'EOF' > ~/.shortcuts/start.sh
#!/bin/bash
pkill tor; pkill haproxy; termux-wake-lock
cd ~/multiplexer
cat << 'HAP' > haproxy.cfg
global
    daemon
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

for i in {1..4}; do
    PORT=$((9060 + i))
    DIR="tor_data_$i"
    mkdir -p $DIR
    echo "SocksPort $PORT" > torrc$i
    echo "DataDirectory $DIR" >> torrc$i
    cat bridge.conf >> torrc$i
    cat proxy.conf >> torrc$i
    echo "Launching Tor instance $i..."
    nohup tor -f torrc$i > /dev/null 2>&1 &
    disown
    [ $i -lt 4 ] && sleep 8
done
nohup haproxy -f haproxy.cfg > /dev/null 2>&1 &
disown
echo "MULTIPLEXER ONLINE: 127.0.0.1:10888"
sleep 4
EOF

# --- GENERATE KILL SWITCH ---
cat << 'EOF' > ~/.shortcuts/tasks/kill_switch.sh
#!/bin/bash
pkill tor; pkill haproxy; termux-wake-unlock
echo "Stopped."
EOF

chmod +x ~/.shortcuts/start.sh
chmod +x ~/.shortcuts/tasks/kill_switch.sh
echo "✅ Setup Finished! Use your widgets to start."
