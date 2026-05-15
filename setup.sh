#!/bin/bash

# --- 1. PREPARE TERMINAL ---
clear
echo "=========================================="
echo "    TOR MULTIPLEXER: ANDROID INSTALLER"
echo "=========================================="
echo "Default Bridge: meek_lite"

# --- 2. PROXY CONFIG ---
echo ""
# The </dev/tty part is the magic trick that stops it from skipping!
read -p "Enter Outbound Proxy (format IP:PORT). Leave blank to skip: " PROXY_IN </dev/tty

# --- 3. INSTALL DEPENDENCIES & CREATE FOLDERS ---
echo ""
echo "Updating packages and installing Tor/HAProxy..."
pkg update -y && pkg install -y tor lyrebird haproxy

mkdir -p ~/.shortcuts/tasks
mkdir -p ~/multiplexer

# --- 4. BUILD CONFIG TEMPLATES ---
# Hardcoding meek_lite as requested
cat << 'EOF'> ~/multiplexer/bridge.conf
UseBridges 1
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge meek_lite 192.0.2.20:80 url=https://1603026938.rsc.cdn77.org front=www.phpmyadmin.net utls=HelloRandomizedALPN
EOF

# Write Proxy Template
if [ -n "$PROXY_IN" ]; then
    echo "Socks5Proxy $PROXY_IN" > ~/multiplexer/proxy.conf
else
    echo "" > ~/multiplexer/proxy.conf
fi

# --- 5. GENERATE THE START WIDGET ---
cat << 'EOF' > ~/.shortcuts/start.sh
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

# Generate configs dynamically from the templates and launch
for i in {1..4}; do
    PORT=$((9060 + i))
    DIR="tor_data_$i"
    mkdir -p $DIR

    echo "SocksPort $PORT" > torrc$i
    echo "DataDirectory $DIR" >> torrc$i
    cat bridge.conf >> torrc$i
    cat proxy.conf >> torrc$i

    echo "Launching Tor instance $i..."
    tor -f torrc$i &
    [ $i -lt 4 ] && sleep 8
done

haproxy -f haproxy.cfg &
echo "=========================================="
echo " MULTIPLEXER ONLINE: 127.0.0.1:10888"
echo "=========================================="
EOF

# --- 6. GENERATE KILL SWITCH ---
cat << 'EOF' > ~/.shortcuts/tasks/kill_switch.sh
#!/bin/bash
pkill tor
pkill haproxy
termux-wake-unlock
echo "Stopped."
EOF

# --- 7. FINAL PERMISSIONS ---
chmod +x ~/.shortcuts/start.sh
chmod +x ~/.shortcuts/tasks/kill_switch.sh

echo ""
echo "✅ Setup Finished!"
echo "Nothing is running yet. Use your Home Screen widgets to start/stop."
