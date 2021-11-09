#!/bin/bash
##################################################################
# This file contains general purpose apt functions to be used 
# in shell scripts
##################################################################

#######################################
# Update apt repositories
#######################################
apt::update(){
    if ! apt update  &> /dev/null; then
        echo  "[ERROR] Failed to update apt"
        exit 1
    fi
}

#######################################
# Upgrade system through apt
#######################################
apt::upgrade(){
    if ! apt upgrade  &> /dev/null; then
        echo  "[ERROR] Failed to upgrade apt"
        exit 1
    fi
}

#######################################
# Install packages through apt
#######################################
apt::install(){
    if [ $# -eq 0 ]; then
        echo  "[ERROR] No packages provided for apt to install"
        exit 1
    elif ! apt install -y $@  &> /dev/null; then
        echo  "[ERROR] Failed to upgrade apt"
        exit 1
    fi
}





