#!/bin/bash
# Test networking functions

# Load networking functions to test
. ./network.sh

utils::create_file(){
  echo "created file in path $1:\n $2" > utils_file.log
}

sysctl(){
    case "$1" in
  "--system")
    echo "applied systcl by reloading" > sysctl.log
  esac
}

iptables(){
    case "$*" in
  "-t nat -A POSTROUTING -o ens3 -j MASQUERADE")
    echo "enabled ip masquerading on interface ens3" > iptables.log
    ;;
  esac
}

# Test that we are able to enable ip forwarding
test_enable_ip_forwarding() {
    network::enable_ip_forwarding

    expected="created file in path /etc/sysctl.d/kmvpn.conf:\n net.ipv4.ip_forward = 1 applied systcl by reloading"
    
    # Make sure that the the function enabled ip forwarding
    assertEquals "$(cat utils_file.log) $(cat sysctl.log)" "$expected"
}

# Test that we are able to enable ip masquerading
test_enable_ip_masquerading() {
    network::enable_ip_masquerading "ens3"

    expected="enabled ip masquerading on interface ens3"
    
    # Make sure that the the function enabled ip masquerading
    assertEquals "$(cat iptables.log)" "$expected"
}

# Test that the function catches the lack of arguments
test_enable_ip_masquerading_with_no_interface() {
    response=$(network::enable_ip_masquerading)
    expected="[ERROR] Interface not provided"
    
    # Make sure that the the function enabled ip masquerading
    assertEquals "$response" "$expected"
}

# Function called to clear the environment
oneTimeTearDown(){
  rm utils_file.log
  rm sysctl.log
  rm iptables.log
}

. /usr/share/shunit2/shunit2