#!/bin/bash


function main(){
    create_log_files
    create_runner_daemon

    echo 'LOG files can be viewed from `~/.deployment/logs`'
}

function create_log_files() {
    echo "Creating log files"
    mkdir ~/.deployment/logs
    touch ~/.deployment/logs/sha-stack.txt
    echo "sha-stack.txt created"
    touch ~/.deployment/logs/github-runner.log
    echo "github-runner.log created"
}

function create_runner_daemon(){
echo "Creating Github Runner Daemon service"
sudo cat << EOF > /etc/systemd/system/github-runner-daemon.service
[Unit]
Description=GitHub Runner Daemon - run.sh
After=network.target

[Service]
ExecStart=/bin/bash -c '/home/$USER/actions-runner/run.sh >> /home/$USER/.deployment/logs/github-runner.log 2>&1'
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


