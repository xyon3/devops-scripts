#!/bin/bash


readonly MSG_ALREADY_INSTALLED="ALREADY_INSTALLED"

if [ "$(id -u)" -eq 0 ]; then
    # prints the user ID, 0 value is root
    echo "This script can't be run as root. Please use a non-root user"
    exit 1
fi


# exit if the server is not ubuntu
if [[ $(awk -F= '$1=="ID" { print $2 }' /etc/os-release) != "ubuntu" ]]; then
    echo "Invalid OS detected, Kindly use Ubuntu Server."
    exit 1
fi

function main() {

    # update the repository and get the latest software
    echo "Updating repository";
    sudo apt-get update && sudo apt-get upgrade -y;

    echo "================================";
    install_tmux;
    echo "================================";
    install_git;
    echo "================================";
    install_nginx;

    # setup docker
    echo "Setting up Docker";
    setup_docker;

}

function setup_docker() {


    if [[ $(docker --version > /dev/null 2>&1 && echo "$MSG_ALREADY_INSTALLED") != "" ]]; then
        echo "command docker is already installed";
        return;
    fi
    
    # Add Docker's official GPG key:
    sudo apt-get update;
    sudo apt-get install ca-certificates curl;
    sudo install -m 0755 -d /etc/apt/keyrings;
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc;
    sudo chmod a+r /etc/apt/keyrings/docker.asc;
    
    echo "Adding Docker repository to apt sources";
    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update;

    echo "Installing Docker";
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y;

    echo "$USER has been added to docker group";
    sudo usermod -aG docker "$USER";

    newgrp docker
    echo "docker group loaded."

    # explicitly enable docker
    echo "explicitly enable docker"
    sudo systemctl enable --now docker
}

function install_nginx(){
    echo "installing nginx"

    if [[ $(nginx --version > /dev/null 2>&1 && echo "$MSG_ALREADY_INSTALLED") != "" ]]; then
        echo "command nginx is already installed";
        return;
    fi

    sudo apt-get install nginx -y
}

function install_git() {

    echo "installing git";

    if [[ $(git --version > /dev/null 2>&1 && echo "$MSG_ALREADY_INSTALLED") != "" ]]; then
        echo "command git is already installed";
        return;
    fi

    sudo apt-get install git -y;

}


function install_tmux() {

    echo "installing tmux";

    if [[ $(tmux --version > /dev/null 2>&1 && echo "$MSG_ALREADY_INSTALLED") != "" ]]; then
        echo "command git is already installed";
        return;
    fi

    sudo apt-get install tmux -y;

}


main
