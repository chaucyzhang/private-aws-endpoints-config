# private-aws-endpoints-config steps

1. register an aws account
2. choose a region
3. launch a instance
4. save ssh keypair as .pem file
5. sudo chmod 400 [filename].pem, if you are using Windows, you can copy the pem file to c:/Windows folder and use WSL to run the chmod command but manually change the permission will be better, it should looks like this: ![image](https://github.com/chaucyzhang/private-aws-endpoints-config/assets/937912/3e999e2d-82f1-4089-830a-7b223c9dd4a2)
6. use  ssh -i "[filename].pem" ubuntu@[aws-instance-address] to connect to the VPS
7. install and config shadowsocks server on this instance:
   # Installing and running shadowsocks on Ubuntu Server
   ## 16.10 yakkety and above
   7.1. Install the the `shadowsocks-libev` package from apt repository.

        sudo apt update
        sudo apt install shadowsocks-libev
   7.2. Save `ss.json` as `/etc/shadowsocks-libev/config.json`.
    Replace **server_port** and **password** in `ss.json` with your own choices.
   7.3. example of ss.json :
   ```
       {
          "server":"0.0.0.0",
          "port_password":{
               "8888":"password1",
               "8889":"password2"
               ...
           },
          "timeout":300,
          "method":"aes-256-cfb",
          "mode":"tcp_only",
          "fast_open":true,
          "nameserver":"8.8.8.8"
       }
   ```
       and you can use ss-manger to lauch the config json by doing:
   
       nohup ss-manager -c /etc/shadowsocks-libev/ss.json -u manager.json &
       
   7.4. Restart the `shadowsocks-libev` service.

        sudo systemctl restart shadowsocks-libev
        sudo systemctl status shadowsocks-libev
   7.5. ### Enable TCP BBR
   ```
   SYSCTL_CONF=/etc/sysctl.d/60-tcp-bbr.conf
   echo "net.core.default_qdisc=fq" | sudo tee $SYSCTL_CONF
   echo "net.ipv4.tcp_congestion_control=bbr" | sudo tee -a $SYSCTL_CONF
   sudo sysctl -p $SYSCTL_CONF

   sysctl net.ipv4.tcp_available_congestion_control
   sysctl net.ipv4.tcp_congestion_control
   lsmod | grep bbr
   ```
   
9. change security group settings on aws website:
   8.1 add a rule to allow internet calls to some specific ports (the ports from shadowsocks server config.json) and save
   8.2 the security group example: ![image](https://github.com/chaucyzhang/private-aws-endpoints-config/assets/937912/bd029f8f-4c37-4d6f-b522-a10d6fc6914a)
   
10. connect your vps server by using a shadowsocks client, the following proxies should be add your ss client tool config file(yml or yaml):
```
  proxies:
  - name: AWS-Tokyo
    password: [password-in-your-ss-server-config]
    cipher: [encrption-method-of-your-server]
    type: ss
    server: [server ip or domain]
    port: [port-in-your-ss-server-config]
    tls: true
    skip-cert-verify: true
  - name: AWS-Hongkong
    password: [password-in-your-ss-server-config]
    cipher: [encrption-method-of-another-server]
    type: ss
    server: [another server ip or domain]
    port: [port-in-your-ss-server-config]
    tls: true
    skip-cert-verify: true
```
11. do not violate any internet laws of your country, enjoy surfing.

### Update
one command config, running following on your aws ec2 instance:
```
sudo wget https://gist.githubusercontent.com/chaucyzhang/e0f5a794a6cd007139afabacfe43f358/raw/dd56f1fb58c458310485318fad8959f084ea8da2/setup.sh
```

```
sh setup.sh
```
