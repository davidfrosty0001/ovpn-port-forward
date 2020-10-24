#!/bin/sh
sudo apt update
sudo apt install openvpn
wget -P ~/ https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.4/EasyRSA-3.0.4.tgz
cd ~
tar xvf EasyRSA-3.0.4.tgz
cd ~/EasyRSA-3.0.4/
cp vars.example vars
nano vars
