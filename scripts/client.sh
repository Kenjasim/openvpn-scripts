#!/bin/bash
##################################################################
# VPN client deployment script
##################################################################

##################################################################
# Imports
##################################################################
. ../pkg/utils/utils.sh #Import utilities functions
. ../pkg/openvpn/openvpn.sh #Import openvpn functions
. ../pkg/systemd/systemd.sh #Import systemd functions
. ../pkg/network/network.sh #Import network functions

##################################################################
# Variables
##################################################################
STATIC_KEY=""
SERVER_IP=""
SERVER_SUBNET=""
DEFAULT_INTERFACE=""

main(){

    # Write the static key to file
    echo "[INFO] Writing static key to default path"
    if ! openvpn::save_key "$STATIC_KEY"; then
        echo "[ERROR] Failed to save static key to default path"
        exit 1
    fi

    # Write the configuration file
    echo "[INFO] Generate client configuration"
    if ! openvpn::gen_client_config $SERVER_IP $SERVER_SUBNET ; then
        echo "[ERROR] Failed to generate client configuration"
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
    if ! systemd::enable shvpn; then 
        echo "[ERROR] Failed to enable systemd service"
        exit 1
    fi

    # Enable the systemd service 
    echo "[INFO] Start service"
    if ! systemd::start shvpn; then 
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