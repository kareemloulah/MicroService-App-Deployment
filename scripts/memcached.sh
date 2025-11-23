#!/bin/bash
set -e

echo "=== Provisioning VM: $(hostname) ==="

if [ -f /etc/os-release ]; then
    . /etc/os-release

########################################################################
# Debian / Ubuntu
########################################################################
if [[ "$ID" = "ubuntu" || "$ID" = "debian" ]]; then

    echo "-- Installing packages --"
    sudo apt update 
    sudo apt install -y curl wget tree vim htop tmux git net-tools \
                        memcached libmemcached-tools

    echo "-- Enabling memcached --"
    sudo systemctl enable --now memcached


########################################################################
# CentOS / Fedora
########################################################################
elif [[ "$ID" = "centos" || "$ID" = "fedora" ]]; then

    echo "-- Installing packages --"
    sudo dnf update -y
    sudo dnf install -y curl wget tree vim htop tmux git net-tools memcached

    echo "-- Allow memcached to listen on all interfaces --"
    sudo sed -i 's/OPTIONS="-l 127.0.0.1"/OPTIONS="-l 0.0.0.0"/' /etc/sysconfig/memcached

    echo "-- Restarting memcached --"
    sudo systemctl daemon-reload
    sudo systemctl enable --now memcached

    echo "-- Configuring Firewall --"
    sudo systemctl enable --now firewalld
    sudo firewall-cmd --zone=public --add-port=11211/tcp --permanent
    sudo firewall-cmd --zone=public --add-port=11111/udp --permanent
    sudo firewall-cmd --reload

fi
fi

echo "=== Provisioning complete ==="
