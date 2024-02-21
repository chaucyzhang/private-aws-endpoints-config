#!/bin/bash
yes Y | sudo apt update;
yes Y | sudo apt install shadowsocks-libev;
wget https://github.com/chaucyzhang/private-aws-endpoints-config/blob/main/default.json -P /etc/shadowsocks-libev
nohup ss-manager -c /etc/shadowsocks-libev/default.json -u manager.json &;
sudo systemctl restart shadowsocks-libev;
sudo systemctl status shadowsocks-libev;
SYSCTL_CONF=/etc/sysctl.d/60-tcp-bbr.conf;
echo "net.core.default_qdisc=fq" | sudo tee $SYSCTL_CONF;
echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a $SYSCTL_CONF;
sudo sysctl -p $SYSCTL_CONF;
sysctl net.ipv4.tcp_available_congestion_control;
sysctl net.ipv4.tcp_congestion_control;
lsmod | grep bbr;