#!/bin/bash
set -e
echo "=== Provisioning VM: $(hostname) ==="
if [ -f /etc/os-release ]; then
      . /etc/os-release
      if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        sudo apt update
        sudo apt install -y curl wget tree vim htop tmux git net-tools
        sudo apt install fontconfig openjdk-17-jre openjdk-17-jdk maven -y
        sudo mkdir -p /opt/apache/
        wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
        sudo tar xvfz apache-tomcat-9.0.112.tar.gz -C /opt/apache
        CATALINA_HOME=/opt/apache/apache-tomcat-9.0.112
        git clone https://github.com/kareemloulah/MicroService-App-Deployment.git
        cd MicroService-App-Deployment && mvn clean install
        sudo cp ~/MicroService-App-Deployment/target/vprofile-v2.war $CATALINA_HOME/webapps/
        sudo $CATALINA_HOME/bin/startup.sh
      elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
        yum update -y -q
        yum install -y -q curl wget vim htop tmux git net-tools
      fi
    fi
echo "=== Provisioning complete ==="
