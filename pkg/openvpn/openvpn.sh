#!/bin/bash
##################################################################
# This file contains general purpose openvpn functions to be used 
# in shell scripts
##################################################################

#######################################
# Generate openvpn key 
#######################################
openvpn::gen_key(){
    if ! openvpn --genkey secret /etc/openvpn/static.key &> /dev/null; then
        echo  "[ERROR] Failed to generate static key"
        exit 1
    fi
}

#######################################
# Save key into the right place 
# Arguments:
# key: Key to save in the file
#######################################
openvpn::save_key(){
    if [ $# -eq 0 ]; then
        echo  "[ERROR] No key provided to save"
        exit 1
    if ! echo "$1" > /etc/openvpn/static.key; then
        echo  "[ERROR] Failed to save static key"
        exit 1
    fi
}


#######################################
# Create OpenVPN Server Configuration
#######################################
openvpn::gen_server_config(){
    server_config="dev tun
ifconfig 10.8.0.1 10.8.0.2
secret /etc/openvpn/static.key
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key"
    if ! echo "$server_config" > /etc/openvpn/config.opvn; then
        echo  "[ERROR] Failed to generate server config"
        exit 1
    fi
}

#######################################
# Create OpenVPN Client Configuration
# Arguments:
# server_ip: IP address of the vpn server
# server_subnet: subnet to give accesss to
#######################################
openvpn::gen_client_config(){
    if [ $# -lt 2 ]; then
        echo  "[ERROR] No serverip or server subnet provided"
        exit 1
    fi 

    client_config="remote $1
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret /etc/openvpn/static.key
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
route $2 255.255.255.0"

    if ! echo "$client_config" > /etc/openvpn/config.opvn; then
        echo  "[ERROR] Failed to generate client config"
        exit 1
    fi
}

#######################################
# Create systemd service
#######################################

openvpn::gen_systemd_service(){

systemd_service="[Unit]
Description=OpenVPN
After=network.target

[Service]
Type=simple
User=root
ExecStart=openvpn --config /etc/openvpn/config.opvn
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target"

    if ! echo "$systemd_service" > /etc/systemd/system/kmvpn.service; then
        echo  "[ERROR] Failed to generate systemd service"
        exit 1
    fi

}