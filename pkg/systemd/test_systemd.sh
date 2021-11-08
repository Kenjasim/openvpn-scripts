#!/bin/bash
# Test the systemd unit

# Load systemd functions to test
. ./systemd.sh

# Fake the output of systemd enable
systemctl(){
    case "$1" in
  "enable")
    echo "ran $@" > systemd.log
    ;;
  "start")
    echo "ran $@" > systemd.log
    ;;
  "stop")
    echo "ran stop" > systemd.log
    ;;
  "restart")
    echo "ran restart" > systemd.log
    ;;
  esac
}

# Test that openvpn is able to generate static key
test_systemd_enable_with_no_service() {
    # Run the systemd enable without a package to enable
    response=$(systemd::enable)
    expected="[ERROR] No service provided"
    
    # Make sure that the key generation ran correctly
    assertEquals "$response" "$expected"
} 

# Test that openvpn is able to generate static key
test_systemd_enable() {
    # Run the systemd enable
    package="kubelet" 
    systemd::enable $package
    expected="ran enable $package"
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat systemd.log)" "$expected"
} 

# Test that openvpn is able to generate static key
test_systemd_start_with_no_service() {
    # Run the systemd enable without a package to enable
    response=$(systemd::start)
    expected="[ERROR] No service provided"
    
    # Make sure that the key generation ran correctly
    assertEquals "$response" "$expected"
} 

# Test that openvpn is able to generate static key
test_systemd_start() {
    # Run the systemd enable
    package="kubelet" 
    systemd::start $package
    expected="ran start $package"
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat systemd.log)" "$expected"
} 


. /usr/share/shunit2/shunit2