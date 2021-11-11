#!/bin/bash
##################################################################
# VPN server deployment script
##################################################################

##################################################################
# Imported Functions
##################################################################

#Import utilities functions
#######################################
# Create a text file with some text in it
# Arguments
# path: The path to store the text file in
# text: The contents to be placed in the file
#######################################
utils::create_file(){
    if [ $# -ne 2 ]; then
        echo  "[ERROR] Path and text not provided"
        exit 1
    elif ! echo "$2" > $1; then
        echo  "[ERROR] Failed to write file to $1"
        exit 1
    fi
}

#Import openvpn functions
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
    elif ! utils::create_file "/etc/openvpn/static.key" "$1"; then
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
    if ! utils::create_file "/etc/openvpn/config.opvn" "$server_config" ; then
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

    if ! utils::create_file "/etc/openvpn/config.opvn" "$client_config"; then
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

    if ! utils::create_file "/etc/systemd/system/kmvpn.service" "$systemd_service"; then
        echo  "[ERROR] Failed to generate systemd service"
        exit 1
    fi

}

#Import systemd functions
#######################################
# Enable a systemd service
# Arguments
# service: The service to enable
#######################################
systemd::enable(){
     if [ $# -eq 0 ]; then
        echo  "[ERROR] No service provided"
        exit 1
    elif ! systemctl enable $1 &> /dev/null; then
        echo  "[ERROR] Failed to enable systemd service $1"
        exit 1
    fi
}

#######################################
# Start a systemd service
# Arguments
# service: The service to enable
#######################################
systemd::start(){
     if [ $# -eq 0 ]; then
        echo  "[ERROR] No service provided"
        exit 1
    elif ! systemctl start $1 &> /dev/null; then
        echo  "[ERROR] Failed to start systemd service $1"
        exit 1
    fi
}


#Import network functions
#######################################
# Enable IP forwarding (root user needed)
#######################################
network::enable_ip_forwarding(){

    # Enable ip forwarding in a new sysctl file
    if ! utils::create_file /etc/sysctl.d/kmvpn.conf "net.ipv4.ip_forward = 1"; then
        echo "[ERROR] Failed to create sysctl file"
        exit 1
    fi

    # Reload Sysctl to apply file
    if ! sysctl --system &> /dev/null; then
        echo "[ERROR] Failed to reload sysctl"
        exit 1
    fi
}

#######################################
# Enable IP Masquerading
# Arguments
# interface: The interface to enable 
# masquerading on
#######################################
network::enable_ip_masquerading(){
    if [ $# -ne 1 ]; then
        echo  "[ERROR] Interface not provided"
        exit 1
    elif ! iptables -t nat -A POSTROUTING -o $1 -j MASQUERADE ; then
        echo  "[ERROR] Failed to enable ip masquerading on interface $1"
        exit 1
    fi
}

##################################################################
# Variables
##################################################################
STATIC_KEY=""
DEFAULT_INTERFACE=""

main(){

    # Write the static key to file
    echo "[INFO] Writing static key to default path"
    if ! openvpn::save_key "$STATIC_KEY"; then
        echo "[ERROR] Failed to save static key to default path"
        exit 1
    fi

    # Write the configuration file
    echo "[INFO] Generate server configuration"
    if ! openvpn::gen_server_config; then
        echo "[ERROR] Failed to generate server configuration"
        exit 1
    fi

    # Create systemd service
    echo "[INFO] Creating systemd service"
    if ! openvpn::gen_systemd_service; then 
        echo "[ERROR] Failed to generate systemd service"
        exit 1
    fi

    # Enable the systemd service 
    echo "[INFO] Enable service"
    if ! systemd::enable kmvpn; then 
        echo "[ERROR] Failed to enable systemd service"
        exit 1
    fi

    # Enable the systemd service 
    echo "[INFO] Start service"
    if ! systemd::start kmvpn; then 
        echo "[ERROR] Failed to start systemd service"
        exit 1
    fi

    # Enable IP Forwarding 
    echo "[INFO] Enable IP Forwarding"
    if ! network::enable_ip_forwarding; then 
        echo "[ERROR] Failed to enable IP Forwarding"
        exit 1
    fi

    # Enable IP Masquerading on default interface
    echo "[INFO] Enable IP Masquerading on VPN Interface"
    if ! network::enable_ip_masquerading $DEFAULT_INTERFACE; then 
        echo "[ERROR] Failed to enable IP Masquerading"
        exit 1
    fi

    # Enable IP Masquerading on VPN interface
    echo "[INFO] Enable IP Masquerading on VPN Interface"
    if ! network::enable_ip_masquerading "tun0"; then 
        echo "[ERROR] Failed to enable IP Masquerading"
        exit 1
    fi
}

if [[ $EUID -ne 0 ]]; then
   echo "[ERROR] This script must be run as root"
   exit 1
fi

main