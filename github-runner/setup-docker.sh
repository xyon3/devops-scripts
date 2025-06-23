#!/bin/bash

declare -l create_network_answer

function main(){

    echo "Setup server for Docker-based deployment"

    read -p "Would you like to setup a docker network for non-published deployments? (y/n/EXIT): " create_network_answer

    if [[ $create_network_answer == "y" || $create_network_answer == "yes" ]]; then
        echo "Creating docker network"

        read -p "Network Name: " docker_network_name
        read -p "Network Subnet: " docker_network_subnet
        read -p "Network Gateway IP: " docker_network_gateway

        docker network create --subnet=$docker_network_subnet --gateway $docker_network_gateway --driver=bridge $docker_network_name

    elif [[ $create_network_answer == "n" || $create_network_answer == "no" ]]; then
        echo "NO DAYO"
    else
        echo "Setup canceled. Exiting..."
        exit
    fi

    copy_relevant_scripts
    create_log_files
    create_runner_daemon

    echo 'LOG files can be viewed from `~/.var/deploy/logs`'
}

function copy_relevant_scripts() {

    scripts_directory="~/.var/deploy/scripts"

    mkdir -p $scripts_directory
    cp "~/devops-scripts/pop_sha_stack.sh" "$scripts_directory/pop_image.sh"
}

function create_log_files() {
    echo "Creating log files"
    mkdir -p ~/.var/deploy/logs
    touch ~/.var/deploy/logs/github-runner.log
    echo "github-runner.log created"
}

function create_runner_daemon(){
echo "Creating Github Runner Daemon service"
sudo cat << EOF > /etc/systemd/system/github-runner-daemon.service
[Unit]
Description=GitHub Runner Daemon - run.sh
After=network.target

[Service]
ExecStart=/bin/bash -c '/home/$USER/actions-runner/run.sh >> /home/$USER/.var/deploy/logs/github-runner.log 2>&1'
WorkingDirectory=/home/$USER/actions-runner
Restart=always
RestartSec=5
User=$USER
Group=docker
Environment=PATH=/usr/bin:/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

# reload the systemd daemon
echo "Reloading systemd"
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

# enable and start the github-runner-daemon
echo "Enabling Github Runner Daemon"
sudo systemctl enable --now github-runner-daemon

echo 'do `systemctl status github-runner-daemon` for information'
}


main


