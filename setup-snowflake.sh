#!/bin/bash
clear
echo "Installing Tor Multiplexer (Bridge: SNOWFLAKE)..."
read -p "Enter Outbound Proxy (IP:PORT) or leave blank: " PROXY_IN </dev/tty

pkg update -y && pkg install -y tor lyrebird haproxy
mkdir -p ~/.shortcuts/tasks ~/multiplexer

cat << 'EOF' > ~/multiplexer/bridge.conf
UseBridges 1
ClientTransportPlugin snowflake exec /data/data/com.termux/files/usr/bin/lyrebird
Bridge snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org/ fronts=app.datapacket.com,www.datapacket.com ice=stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.telnyx.com:3478,stun:stun.hot-chilli.net:3478,stun:stun.fitauto.ru:3478,stun:stun.m-online.net:3478 utls-imitate=hellorandomizedalpn
Bridge snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org/ fronts=app.datapacket.com,www.datapacket.com ice=stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.telnyx.com:3478,stun:stun.hot-chilli.net:3478,stun:stun.fitauto.ru:3478,stun:stun.m-online.net:3478 utls-imitate=hellorandomizedalpn
EOF

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
