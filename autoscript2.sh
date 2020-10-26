#!/bin/sh
sudo apt update -y
sudo apt install openvpn -y
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz
cd ~
tar xvf EasyRSA-3.0.8.tgz
cd ~/EasyRSA-3.0.8/
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/vars
./easyrsa init-pki
#
#Press Yes
#
yes | ./easyrsa build-ca nopass
#
#Make sure you write yes here with no space
#
yes | ./easyrsa init-pki
#
#Press Yes
#
yes | ./easyrsa gen-req server nopass
#
#Press Enter
#
sudo cp ~/EasyRSA-3.0.8/pki/private/server.key /etc/openvpn/
cp ~/EasyRSA-3.0.8/pki/reqs/server.req /tmp/
cd ~/EasyRSA-3.0.8/
./easyrsa import-req /tmp/server.req server
#
#Press Enter
#
yes | ./easyrsa build-ca nopass
#
#press Yes
#
yes | ./easyrsa sign-req server server
#
#Enter yes
#
cp pki/issued/server.crt /tmp/
cp pki/ca.crt /tmp/
sudo cp /tmp/{server.crt,ca.crt} /etc/openvpn/
cd ~/EasyRSA-3.0.8/
./easyrsa gen-dh
#
#
#
openvpn --genkey --secret ta.key
sudo cp ~/EasyRSA-3.0.8/ta.key /etc/openvpn/
sudo cp ~/EasyRSA-3.0.8/pki/dh.pem /etc/openvpn/
mkdir -p ~/client-configs/keys
chmod -R 700 ~/client-configs
cd ~/EasyRSA-3.0.8/
yes | ./easyrsa gen-req client1 nopass
#
#press enter
#
cp pki/private/client1.key ~/client-configs/keys/
cp pki/reqs/client1.req /tmp/
cd ~/EasyRSA-3.0.8/
yes | ./easyrsa import-req /tmp/client1.req client1
#
#
#
yes | ./easyrsa sign-req client client1
#
#Enter yes
#
cp pki/issued/client1.crt /tmp/
cp /tmp/client1.crt ~/client-configs/keys/
cp ~/EasyRSA-3.0.8/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/ca.crt ~/client-configs/keys/
sudo mkdir -p /etc/openvpn/
sudo wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/server.conf
sudo cp server.conf /etc/openvpn/server.conf
sudo mkdir /etc/openvpn/ccd
sudo echo "ifconfig-push 10.8.0.201 255.255.255.0" > /etc/openvpn/ccd/client1
sudo sed -i '28 s/^#//' /etc/sysctl.conf
ip route | grep default
#
#confirm that your internet is etho, if not you need to before.rules
#
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/before.rules
sudo mv -f before.rules /etc/ufw/before.rules
wget https://raw.githubusercontent.com/davidfrosty0001/ovpn-port-forward/master/ufw
sudo mv -f ufw /etc/default/ufw
#
#
#
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



#
#This are not confirm yet.
#

sudo apt-get install iptables-persistent -y
iptables-save > /etc/iptables/rules.v4
iptables-save > /etc/sysconfig/iptables
touch /etc/iptables.blynk.rules
echo '#!/bin/sh' > /etc/network/if-up.d/iptables
echo "iptables-restore < /etc/iptables.blynk.rules" >> /etc/network/if-up.d/iptables
chmod +x /etc/network/if-up.d/iptables

echo '#!/bin/sh' > /etc/network/if-down.d/iptables
echo "iptables-save > /etc/iptables.blynk.rules" >> /etc/network/if-down.d/iptables
chmod +x /etc/network/if-down.d/iptables

service networking restart

sudo iptables -t nat -A PREROUTING -p tcp --dport 80:82 -j DNAT --to-dest 10.8.0.201:80-82
sudo iptables -t nat -A POSTROUTING -d 10.8.0.201 -p tcp --dport 80:82 -j SNAT --to-source 10.8.0.1
sudo iptables -t nat -A PREROUTING -p udp --dport 2404 -j DNAT --to-dest 10.8.0.201:2404
sudo iptables -t nat -A POSTROUTING -d 10.8.0.201 -p udp --dport 2404 -j SNAT --to-source 10.8.0.1

