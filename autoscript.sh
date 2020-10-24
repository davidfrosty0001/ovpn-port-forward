#!/bin/sh
sudo apt update
sudo apt install openvpn
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
cd ~
tar xvf EasyRSA-3.0.8.tgz
cd ~/EasyRSA-3.0.8/
cp vars.example vars
nano vars
*
*
*
./easyrsa init-pki
./easyrsa build-ca nopass
*
*
*
cd EasyRSA-3.0.8/
./easyrsa init-pki
./easyrsa gen-req server nopass
sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/
cp ~/EasyRSA-3.0.8/pki/reqs/server.req /tmp
cd EasyRSA-3.0.8/
./easyrsa import-req /tmp/server.req server
./easyrsa sign-req server server
*
*
*
cp pki/issued/server.crt /tmp
cp pki/ca.crt /tmp
sudo cp /tmp/{server.crt,ca.crt} /etc/openvpn/
cd EasyRSA-3.0.8/
./easyrsa gen-dh
openvpn --genkey --secret ta.key
sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/
sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
cd ~/EasyRSA-3.0.8/
./easyrsa gen-req client1 nopass
cp pki/private/client1.key ~/client-configs/keys/
cp pki/reqs/client1.req /tmp
cd EasyRSA-3.0.8/
./easyrsa import-req /tmp/client1.req client1
./easyrsa sign-req client client1
*
*
*
cp pki/issued/client1.crt /tmp
cp /tmp/client1.crt ~/client-configs/keys/
cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/
sudo mkdir -p /etc/openvpn/
sudo wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/server.conf
sudo cp server.conf /etc/openvpn/server.conf
sudo sed -i '28 s/^#//' /etc/sysctl.conf

ip route | grep default
*
*
*
sudo nano /etc/ufw/before.rules
*
*
*
sudo nano /etc/default/ufw
*
*
*
sudo ufw allow 1194/udp
sudo ufw allow OpenSSH
sudo ufw disable
sudo ufw enable
sudo systemctl start openvpn@server
sudo systemctl status openvpn@server
sudo systemctl enable openvpn@server
mkdir -p ~/client-configs/files
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/base.conf
cp base.conf ~/client-configs/base.conf
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/make_config.sh
cp make_config.sh ~/client-configs/make_config.sh
chmod 700 ~/client-configs/make_config.sh
cd ~/client-configs
sudo ./make_config.sh client1
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/ports.py
python3 ports.py 2404 both
ls ~/client-configs/files



