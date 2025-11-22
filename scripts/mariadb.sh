#!/bin/bash

set -e
echo "=== Provisioning VM: $(hostname) ==="
if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        sudo apt update
        sudo apt install -y -qq curl wget tree vim htop tmux git net-tools
        sudo apt-get install apt-transport-https curl -y 
        sudo mkdir -p /etc/apt/keyrings
        sudo curl -o /etc/apt/keyrings/mariadb-keyring.pgp 'https://mariadb.org/mariadb_release_signing_key.pgp'

        sudo echo "# MariaDB 12.2 repository list - created 2025-11-22 14:06 UTC
        # https://mariadb.org/download/
        X-Repolib-Name: MariaDB
        Types: deb
        # deb.mariadb.org is a dynamic mirror if your preferred mirror goes offline. See https://mariadb.org/mirrorbits/ for details.
        # URIs: https://deb.mariadb.org/12.rc/ubuntu
        URIs: https://mariadb.mirror.liquidtelecom.com/repo/12.2/ubuntu
        Suites: jammy
        Components: main main/debug
        Signed-By: /etc/apt/keyrings/mariadb-keyring.pgp" >> sudo tee /etc/apt/sources.list.d/mariadb.sources

        sudo apt-get update
        sudo apt-get install mariadb-server -y

        echo "& y y kareem kareem y n n y" | ./usr/bin/mysql_secure_installation
        echo "CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'admin';
        GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%';
        FLUSH PRIVILEGES;" | mariadb -u root -p"kareem" 

      elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
        yum update -y -q
        yum install -y -q curl wget vim htop tmux git net-tools
      fi
    fi

echo "=== Provisioning complete ==="
