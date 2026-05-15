#!/bin/bash
clear
echo "Installing Tor Multiplexer (Mode: DIRECT)..."
read -p "Enter Outbound Proxy (IP:PORT) or leave blank: " PROXY_IN </dev/tty

pkg update -y && pkg install -y tor lyrebird haproxy
mkdir -p ~/.shortcuts/tasks ~/multiplexer

echo "UseBridges 0" > ~/multiplexer/bridge.conf

[ -n "$PROXY_IN" ] && echo "Socks5Proxy $PROXY_IN" > ~/multiplexer/proxy.conf || echo "" > ~/multiplexer/proxy.conf

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
