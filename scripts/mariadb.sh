#!/bin/bash

set -e
echo "=== Provisioning VM: $(hostname) ==="

if [ -f /etc/os-release ]; then
    . /etc/os-release

########################################################################
# Ubuntu / Debian
########################################################################
if [[ "$ID" = "ubuntu" || "$ID" = "debian" ]]; then

    echo "-- Installing prerequisites --"
    sudo apt update
    sudo apt install -y -qq curl wget tree vim htop tmux git net-tools apt-transport-https

    echo "-- Adding MariaDB 12.2 repo (Deb822 format) --"
    sudo mkdir -p /etc/apt/keyrings
    sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp https://mariadb.org/mariadb_release_signing_key.pgp

    sudo tee /etc/apt/sources.list.d/mariadb.sources >/dev/null <<EOF
X-Repolib-Name: MariaDB
Types: deb
URIs: https://mariadb.mirror.liquidtelecom.com/repo/12.2/ubuntu
Suites: jammy
Components: main main/debug
Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp
EOF

    echo "-- Installing MariaDB --"
    sudo apt update
    sudo apt install -y mariadb-server

    sudo systemctl enable --now mariadb

    echo "-- Creating database + users --"
    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin';
FLUSH PRIVILEGES;
EOF

    echo "-- Importing DB backup --"
    cd /tmp
    wget -q https://raw.githubusercontent.com/abdelrahmanonline4/sourcecodeseniorwr/refs/heads/Master/src/main/resources/db_backup.sql
    mariadb -u root accounts < /tmp/db_backup.sql


########################################################################
# CentOS / Fedora
########################################################################
elif [[ "$ID" = "centos" || "$ID" = "fedora" ]]; then

    echo "-- Installing MariaDB on CentOS/Fedora --"
    dnf update -y
    dnf install -y epel-release
    dnf install -y -q curl wget vim htop tmux git net-tools mariadb-server firewalld

    systemctl enable mariadb
    systemctl start mariadb
    echo "-- Creating database + users --"
    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'%' IDENTIFIED BY 'admin';
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin';
FLUSH PRIVILEGES;
EOF

    echo "-- Importing DB backup --"
    cd /tmp
    wget -q https://raw.githubusercontent.com/abdelrahmanonline4/sourcecodeseniorwr/refs/heads/Master/src/main/resources/db_backup.sql
    mariadb -u root accounts < /tmp/db_backup.sql

    echo "-- Configuring firewall --"
    systemctl enable --now firewalld
    firewall-cmd --zone=public --add-port=3306/tcp --permanent
    firewall-cmd --reload

    systemctl restart mariadb

fi
fi

echo "=== Provisioning complete ==="
