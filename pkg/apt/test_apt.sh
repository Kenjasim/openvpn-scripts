#!/bin/bash
# file: examples/party_test.sh

# Load apt function to test
. ./apt.sh

# Fake the output of the apt debian package manager
apt(){
    case "$1" in
  "update")
    echo "ran update" > apt.log
    ;;
  "upgrade")
    echo "ran upgrade" > apt.log
    ;;
  "install")
    echo "ran $@" > apt.log
    ;;
  esac
}

# Test that the apt update function runs apt update
test_apt_update() {
    # Run the apt update
    apt::update

    # Make sure that the update ran correctly
    assertEquals "$(cat apt.log)" "ran update"
} 

# Test that the apt upgrade function runs apt upgrade
test_apt_upgrade() {
    # Run the apt update
    apt::upgrade

    # Make sure that the update ran correctly
    assertEquals "$(cat apt.log)" "ran upgrade"
} 

# Test that the apt install function returns an error if the function doesnt run
test_apt_install_fails_with_no_package() {
    # Run the apt install
    first_line=$(apt::install)

    expected="[ERROR] No packages provided for apt to install"

    # Make sure that the update ran correctly
    assertEquals "$first_line" "$expected"
} 

# Test that the apt install can install one package
test_apt_install_package() {
    
    # Packages for apt to install 
    packages="curl"
    
    # Run the apt install
    apt::install $packages

    expected="ran install -y $packages"

    # Make sure that the update ran correctly
    assertEquals "$(cat apt.log)" "$expected"
} 

# Test that the apt install function can install multiple packages
test_apt_install_packages() {
    
    # Packages for apt to install 
    packages="apt-transport-https ca-certificates curl gnupg lsb-release"
    
    # Run the apt install
    apt::install $packages

    expected="ran install -y $packages"

    # Make sure that the update ran correctly
    assertEquals "$(cat apt.log)" "$expected"
} 
. /usr/share/shunit2/shunit2

