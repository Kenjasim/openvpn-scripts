# OpenVPN VNF Package

This repository contains simple, unit tested, scripts to install and set up a simple OpenVPN server and client.

## Steps

1. Install openvpn on both server and client (using apt for now)
2. Generate a static key or use a preconfigured (hard coded) one
3. Make sure the same static key is on the server and client
4. Create the configuration files `/etc/openvpn/config.opvn`
5. Create the systemd services and start them
6. Enable IP forwarding
7. Allow client to reach server subnet by adding a route to the client side and enabling IP Masquradeing on server side.

## Prerequisites

The scripts are built and tested to run on Linux (Ubuntu 20.04 machines). The machines require the use of the apt package manager to install any required packages, as a result this script requires an Ubuntu/Debian based OS to run. The easiest option will be to run the script on Ubuntu 20.04 which can be downloaded here

## VPN Server Setup

Transfer the server.sh script to the machine which will act as the VPN Server.

```bash
sudo ./server.sh 
```

## VPN Client Setup

Transfer the client.sh script to the machine which will act as the VPN client. The machine MUST be on the same network as the cell for the vpn to have access to it. The script will require the public IP of the vpn server and the subnet of the server network. For example if the server  machine's internal ip is 192.168.0.25 you should pass in 192.168.0.0

```bash
sudo ./client.sh 10.0.0.0 10.40.10.0
```

To check if the script has succeded you can check the status of the systemd service. If the status is active then the script ran successfuly.

```bash
$ sudo systemctl status shvpn.service

● shvpn.service - OpenVPN
     Loaded: loaded (/etc/systemd/system/shvpn.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2022-02-01 12:38:28 UTC; 4s ago
   Main PID: 2179 (openvpn)
      Tasks: 1 (limit: 9561)
     Memory: 1.1M
     CGroup: /system.slice/shvpn.service
             └─2179 /usr/sbin/openvpn --config /etc/openvpn/config.opvn
```
