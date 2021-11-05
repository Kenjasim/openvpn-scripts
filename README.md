# OpenVPN VNF Package

This repository will contain the sscripts and VNF packages needed to deploy a VPN server and VPN client onto OSM

## Steps

1. Install openvpn on both server and client (using apt for now)
2. Generate a static key or use a preconfigured (hard coded) one
3. Make sure the same static key is on the server and client
4. Create the configuration files `/etc/openvpn/config.opvn`
5. Create the systemd services and start them
6. Enable IP forwarding
7. Allow client to reach server subnet by adding a route to the client side and enabling IP Masquradeing on server side

