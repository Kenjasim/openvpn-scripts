#!/bin/bash
##################################################################
# This file contains general purpose networking functions to be 
# used in shell scripts
##################################################################

##################################################################
# Imports
##################################################################
. ../pkg/utils/utils.sh #Import utilities functions

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