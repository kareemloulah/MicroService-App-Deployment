#!/bin/bash
set -e

echo "=== Provisioning VM: $(hostname) ==="

if [ -f /etc/os-release ]; then
    . /etc/os-release

    ##############################
    # Debian / Ubuntu section
    ##############################
    if [[ "$ID" = "ubuntu" || "$ID" = "debian" ]]; then
        echo "-- Updating system packages --"
        apt update
        apt install -y curl wget tree vim htop tmux git net-tools gnupg apt-transport-https

        echo "-- Installing RabbitMQ Repo & Erlang --"
        curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" \
            | gpg --dearmor \
            | tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

        cat <<EOF >/etc/apt/sources.list.d/rabbitmq.list
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
EOF

        apt-get update -y

        apt-get install -y erlang-base \
            erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
            erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
            erlang-runtime-tools erlang-snmp erlang-ssl \
            erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

        apt-get install -y rabbitmq-server --fix-missing

        echo "-- RabbitMQ installed successfully on Debian/Ubuntu --"


    ##############################
    # CentOS / Fedora section
    ##############################
    elif [[ "$ID" = "centos" || "$ID" = "fedora" ]]; then
        echo "-- Updating system packages --"
        dnf update -y
        dnf install -y curl wget vim htop tmux git net-tools centos-release-rabbitmq-38 firewalld

        dnf --enablerepo=centos-rabbitmq-38 -y install rabbitmq-server

        systemctl enable --now rabbitmq-server

        echo "-- Configuring RabbitMQ --"
        echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config

        rabbitmqctl add_user test test || true
        rabbitmqctl set_user_tags test administrator
        rabbitmqctl set_permissions -p / test ".*" ".*" ".*"

        systemctl restart rabbitmq-server

        echo "-- Configuring Firewall --"
        sudo systemctl enable --now firewalld
        sudo firewall-cmd --add-port=5672/tcp
        sudo firewall-cmd --runtime-to-permanent

    fi
fi

echo "=== Provisioning complete ==="
