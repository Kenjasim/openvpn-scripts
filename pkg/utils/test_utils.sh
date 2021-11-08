#!/bin/bash
# Test the utils unit

# Load systemd functions to test
. ./utils.sh

# Test that we are able to create file
test_utils_create_file() {
    # Run the systemd enable without a package to enable
    path="test.txt"
    text="Example Text File"
    
    utils::create_file "$path" "$text"
    
    # Make sure that the key generation ran correctly
    assertEquals "$(cat $path)" "$text"
}

# Test that the function will error if only one arg is passed
test_error_when_creating_file() {
    # Run the function without text to write to
    path="test.txt"
    
    response=$(utils::create_file "$path")
    expected="[ERROR] Path and text not provided" 
    
    # Make sure that the key generation ran correctly
    assertEquals "$response" "$expected"
}

# Test that the function can make empty files
test_creating_empty_file() {
    # Run the function without text to write to
    path="test.txt"

    utils::create_file "$path" "" 
    
    # Make sure that the function ran well
    assertEquals "$(cat $path)" ""
}

# Test that the function can write multi-line files
test_creating_empty_file() {
    # Run the function without text to write to
    path="test.txt"
    text="Hello
How are you
Fine"

    utils::create_file "$path" "$text" 
    
    # Make sure that the function ran well
    assertEquals "$(cat $path)" "$text"
}

Function called to clear the environment
oneTimeTearDown(){
  rm test.txt
}

. /usr/share/shunit2/shunit2