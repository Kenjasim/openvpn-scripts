#!/bin/bash
##################################################################
# This file contains general purpose openvpn functions to be used 
# in shell scripts
##################################################################

#######################################
# Update apt repositories
#######################################
openvpn::gen_key(){
    if ! openvpn --genkey secret static.key &> /dev/null; then
        echo  "[ERROR] Failed to generate static key"
        exit 1
    fi
}