#!/bin/bash
set -e
echo "=== Provisioning VM: $(hostname) ==="
if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        sudo apt update -qq
        sudo apt install -y curl wget tree vim htop tmux git net-tools
        sudo apt-get install gnupg apt-transport-https -y
        ## Team RabbitMQ's signing key
        curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

        ## Add apt repositories maintained by Team RabbitMQ
        sudo echo "## Modern Erlang/OTP releases ##
        deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
        deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
        ## Latest RabbitMQ releases
        ##
        deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
        deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main" >> sudo tee /etc/apt/sources.list.d/rabbitmq.list
        ## Update package indices
        sudo apt-get update -y
        ## Install Erlang packages
        sudo apt-get install -y erlang-base \
                                erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                                erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                                erlang-runtime-tools erlang-snmp erlang-ssl \
                                erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl
        ## Install rabbitmq-server and its dependencies
        sudo apt-get install rabbitmq-server -y --fix-missing
      elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
        yum update -y -q
        yum install -y -q curl wget vim htop tmux git net-tools
      fi
    fi
echo "=== Provisioning complete ==="
