#!/bin/bash

# --- 1. PREPARE TERMINAL ---
clear
echo "=========================================="
echo "    TOR MULTIPLEXER: ANDROID INSTALLER"
echo "=========================================="

read -p "Enter Outbound Proxy (IP:PORT) or leave blank: " PROXY_IN </dev/tty

# --- 2. AUTO-FIX REPO ---
echo "Optimizing repository mirror..."
termux-change-repo << EOR
1
1
EOR
pkg update -y && pkg install -y tor lyrebird haproxy

mkdir -p ~/.shortcuts/tasks ~/multiplexer

# --- 3. CONFIG TEMPLATES ---
cat << 'EOF' > ~/multiplexer/bridge.conf
UseBridges 1
ClientTransportPlugin meek_lite,obfs2,obfs3,obfs4,scramblesuit,webtunnel exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge meek_lite 192.0.2.20:80 url=https://1603026938.rsc.cdn77.org front=www.phpmyadmin.net utls=HelloRandomizedALPN
EOF

[ -n "$PROXY_IN" ] && echo "Socks5Proxy $PROXY_IN" > ~/multiplexer/proxy.conf || echo "" > ~/multiplexer/proxy.conf

# --- 4. GENERATE START WIDGET ---
cat << 'EOF' > ~/.shortcuts/start.sh
#!/bin/bash
pkill tor; pkill haproxy; termux-wake-lock
cd ~/multiplexer

# HAProxy Config for 5 instances
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
    server tor5 127.0.0.1:9065 check
HAP

echo "Starting 5 Tor Engines..."

# Launch 5 Tor Instances
for i in {1..5}; do
    PORT=$((9060 + i))
    DIR="tor_data_$i"
    mkdir -p $DIR
    echo "SocksPort $PORT" > torrc$i
    echo "DataDirectory $DIR" >> torrc$i
    cat bridge.conf >> torrc$i
    cat proxy.conf >> torrc$i
    
    # Pin 1, 2, and 3 to Netherlands
    if [ "$i" -le 3 ]; then
        echo "EntryNodes {nl}" >> torrc$i
        echo "ExitNodes {nl}" >> torrc$i
        echo "StrictNodes 1" >> torrc$i
    fi

    echo " -> Booting instance $i..."
    nohup tor -f torrc$i > /dev/null 2>&1 &
    disown
    [ $i -lt 5 ] && sleep 8
done

echo "Starting HAProxy..."
nohup haproxy -f haproxy.cfg > /dev/null 2>&1 &
disown

echo "=========================================="
echo " MULTIPLEXER ONLINE: 127.0.0.1:10888"
echo " You can safely close this terminal."
echo "=========================================="
sleep 3
EOF

# --- 5. KILL SWITCH ---
cat << 'EOF' > ~/.shortcuts/tasks/kill_switch.sh
#!/bin/bash
pkill tor; pkill haproxy; termux-wake-unlock
echo "Multiplexer Stopped."
EOF

chmod +x ~/.shortcuts/start.sh ~/.shortcuts/tasks/kill_switch.sh
echo "✅ Setup Finished!"
