#!/bin/bash


echo "cleaning up"

function main() {
    for_docker
}


function for_docker() {
    rm -rf ~/.deployment
    clean_daemon
}

function clean_daemon(){
    sudo systemctl stop github-runner-daemon
    sudo systemctl disable github-runner-daemon
    
    sudo rm -rf /etc/systemd/system/github-runner-daemon.service
    sudo systemctl daemon-reexec
    sudo systemctl daemon-reload
}


main
