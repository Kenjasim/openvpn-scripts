#!/bin/bash
##################################################################
# This file contains general purpose systemd functions to be used 
# in shell scripts
##################################################################

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