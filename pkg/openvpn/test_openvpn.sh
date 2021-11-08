#!/bin/bash
# file: examples/party_test.sh

# Load apt function to test
. ./openvpn.sh

# Fake the output of the apt debian package manager
openvpn(){
    case "$*" in
  "--genkey secret /etc/openvpn/static.key")
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


# Test that openvpn is able to generate static key
test_key_save() {
    static_key="test"

    # Run the static key save
    openvpn::save_key $static_key
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat /etc/openvpn/static.key)" "$static_key"
} 

# Test that openvpn is able to generate the server config
test_server_config() {
    server_config="dev tun
ifconfig 10.8.0.1 10.8.0.2
secret /etc/openvpn/static.key
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key"

    # Run the server generation
    openvpn::gen_server_config
    
    # Make sure that the server config generation ran correctly
    assertEquals "$(cat /etc/openvpn/config.opvn)" "$server_config"
}


test_client_config(){

  server_ip="10.40.1.1"
  server_subnet="10.40.1.0"
  client_config="remote $server_ip
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret /etc/openvpn/static.key
comp-lzo
keepalive 10 60
ping-timer-rem
persist-tun
persist-key
route $server_subnet 255.255.255.0"

  # Run the client server configuration
  openvpn::gen_client_config $server_ip $server_subnet
  
  # Make sure that the key generation ran correctly
  assertEquals "$(cat /etc/openvpn/config.opvn)" "$client_config"

}

test_systemd_service_gen(){
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
  # Run the client server configuration
  openvpn::gen_systemd_service
  
  # Make sure that the systemd generation ran correctly
  assertEquals "$(cat /etc/systemd/system/kmvpn.service)" "$systemd_service"

}

# Function called to clear the environment
oneTimeTearDown(){
  rm /etc/openvpn/static.key
  rm /etc/openvpn/config.opvn
}


. /usr/share/shunit2/shunit2

