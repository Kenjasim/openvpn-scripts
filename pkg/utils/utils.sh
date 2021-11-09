#!/bin/bash
##################################################################
# This file contains general purpose utility functions to be used 
# in shell scripts
##################################################################

#######################################
# Create a text file with some text in it
# Arguments
# path: The path to store the text file in
# text: The contents to be placed in the file
#######################################
utils::create_file(){
    if [ $# -ne 2 ]; then
        echo  "[ERROR] Path and text not provided"
        exit 1
    elif ! echo "$2" > $1; then
        echo  "[ERROR] Failed to write file to $1"
        exit 1
    fi
}