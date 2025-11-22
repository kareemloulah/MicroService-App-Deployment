#!/bin/bash
set -e
echo "=== Provisioning VM: $(hostname) ==="
if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        sudo apt update
        sudo apt install -y curl wget tree vim htop tmux git net-tools
        sudo apt install -y nginx
      elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
        yum update -y -q
        yum install -y -q curl wget vim htop tmux git net-tools
      fi
    fi
echo "=== Provisioning complete ==="
