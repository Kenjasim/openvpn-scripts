#!/bin/bash
# file: examples/party_test.sh

# Load apt function to test
. ./openvpn.sh

created_file_expected="created file"

utils::create_file(){
  echo "created file in path $1:\n $2" > utils_file.log
}

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


# Test that openvpn is able to save static key
test_key_save() {
    static_key="-----BEGIN OpenVPN Static key V1-----
b7e7bac410594bd6f33f458914ff8e08
c8e9ed0f9ecbbb558f4970c9f08462a5
084bad046676cfadbc1401d8bcb5b892
d5055d8b11968de60780b02400dd2944
3f0008beb114d89c883a30201c2759fa
67b2887ae70031a416c1980d943c5d29
6ae6ad23c179789c8ae7f8cac2ae427c
5e3d71954e9cd57909247ab3928868b4
693b5cb81fc8c088f9c6b253b9ec95f2
558050645a973d02934e3b85b2820432
0d3c6cf72e9d9fb354c78fd8342b1f4b
af87e2fa9b0e8bab1ae7148aa83ed542
fb201aa82c8b49361d5fed4df6b5c3ef
9b392439e378150e2388e697285e5317
492f380149003e667bae07fe577b0368
2961e817fda98004e3ac2d6a06c0f538
-----END OpenVPN Static key V1-----"
    # Run the static key save
    openvpn::save_key "$static_key"

    expected="created file in path /etc/openvpn/static.key:\n $static_key"
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat utils_file.log)" "$expected"
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
    expected="created file in path /etc/openvpn/config.opvn:\n $server_config"
    
    # Make sure that the server config generation ran correctly
    assertEquals "$(cat utils_file.log)" "$expected"
}

# Test that openvpn is able to generate the client config
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
  expected="created file in path /etc/openvpn/config.opvn:\n $client_config"
    
  # Make sure that the client config generation ran correctly
  assertEquals "$(cat utils_file.log)" "$expected"

}

# Test that openvpn is able to generate the systemd service
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
  # Run the systemd service creation
  openvpn::gen_systemd_service
  expected="created file in path /etc/systemd/system/kmvpn.service:\n $systemd_service"
    
  # Make sure that the systemd generation ran correctly
  assertEquals "$(cat utils_file.log)" "$expected"


}

# Function called to clear the environment
oneTimeTearDown(){
  rm utils_file.log
  rm openvpn.log
}


. /usr/share/shunit2/shunit2

