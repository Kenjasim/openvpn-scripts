#!/bin/bash
# file: examples/party_test.sh

# Load apt function to test
. ./openvpn.sh

# Fake the output of the apt debian package manager
openvpn(){
    case "$*" in
  "--genkey secret static.key")
    echo "generated key" > openvpn.log
    ;;
  "upgrade")
    echo "ran upgrade" > apt.log
    ;;
  "install")
    echo "ran $@" > apt.log
    ;;
  esac
}

# Test that openvpn is able to generate static key
test_key_generation() {
    # Run the static key gen
    openvpn::gen_key
    expected="generated key"
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat openvpn.log)" "$expected"
} 

. /usr/share/shunit2/shunit2

