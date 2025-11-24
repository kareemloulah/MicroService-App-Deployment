#!/bin/bash
set -e

echo "=== Provisioning VM: $(hostname) ==="

if [ -f /etc/os-release ]; then
    . /etc/os-release
fi

###########################################################################
# UBUNTU / DEBIAN
###########################################################################
if [[ "$ID" = "ubuntu" || "$ID" = "debian" ]]; then

    echo "-- Installing packages --"
    apt update
    apt install -y curl wget tree vim htop tmux git net-tools fontconfig \
        openjdk-17-jre openjdk-17-jdk maven

    echo "-- Creating tomcat user --"
    useradd -m -U -d /usr/local/tomcat -s /bin/false tomcat || true

    echo "-- Downloading Tomcat --"
    mkdir -p /opt/apache
    cd /opt/apache
    wget -q https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
    tar xzf apache-tomcat-9.0.112.tar.gz

    CATALINA_HOME=/opt/apache/apache-tomcat-9.0.112
    TOMCAT_DIR=$CATALINA_HOME   # <== FIXED

    echo "-- Setting Tomcat permissions --"
    chown -R tomcat:tomcat $CATALINA_HOME
    chmod +x $CATALINA_HOME/bin/*.sh

    echo "-- Cloning & building app --"
    cd /opt/
    git clone https://github.com/kareemloulah/MicroService-App-Deployment.git || true
    cd MicroService-App-Deployment
    mvn clean install -DskipTests

    echo "-- Deploying WAR --"
    cp target/vprofile-v2.war $CATALINA_HOME/webapps/

    echo "-- Editing Tomcat configuration (users + manager access) --"

    cat <<EOF >"$CATALINA_HOME/conf/tomcat-users.xml"
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="admin" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOF

    # FIXED: Correct paths for context.xml
    sed -i '/<Valve/,/\/>/d' $TOMCAT_DIR/webapps/manager/META-INF/context.xml
    sed -i '/<Valve/,/\/>/d' $TOMCAT_DIR/webapps/host-manager/META-INF/context.xml

    echo "-- Creating Tomcat service --"
    cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat Application Server
After=network.target

[Service]
User=tomcat
Group=tomcat
Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
Environment=CATALINA_HOME=$CATALINA_HOME
Environment=CATALINA_BASE=$CATALINA_HOME
ExecStart=$CATALINA_HOME/bin/catalina.sh run
ExecStop=$CATALINA_HOME/bin/shutdown.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable tomcat
    systemctl start tomcat

###########################################################################
# CENTOS / FEDORA
###########################################################################
elif [[ "$ID" = "centos" || "$ID" = "fedora" ]]; then

    echo "-- Installing packages --"
    dnf update -y
    dnf install -y curl wget vim htop tmux git net-tools \
        java-17-openjdk java-17-openjdk-devel maven firewalld

    echo "-- Downloading Tomcat --"
    cd /tmp
    rm -f apache-tomcat-9.0.112.tar.gz
    wget -q https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
    tar xzf apache-tomcat-9.0.112.tar.gz

    echo "-- Creating tomcat user --"
    useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat || true

    echo "-- Installing Tomcat --"
    mkdir -p /usr/local/tomcat
    cp -r /tmp/apache-tomcat-9.0.112/* /usr/local/tomcat/
    chown -R tomcat:tomcat /usr/local/tomcat
    chmod +x /usr/local/tomcat/bin/*.sh

    TOMCAT_DIR=/usr/local/tomcat

    cat <<EOF >"$TOMCAT_DIR/conf/tomcat-users.xml"
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="admin" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOF

    sed -i '/<Valve/,/\/>/d' $TOMCAT_DIR/webapps/manager/META-INF/context.xml
    sed -i '/<Valve/,/\/>/d' $TOMCAT_DIR/webapps/host-manager/META-INF/context.xml

    echo "-- Creating systemd service --"
    cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat Application Server
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINA_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable tomcat
    systemctl start tomcat

    echo "-- Opening firewall --"
    systemctl enable --now firewalld
    firewall-cmd --zone=public --add-port=8080/tcp --permanent
    firewall-cmd --reload

fi

###########################################################################
# APPLICATION BUILD & DEPLOYMENT
###########################################################################

echo "Cloning backend application..."
cd /tmp
rm -rf sourcecodeseniorwr
git clone https://github.com/abdelrahmanonline4/sourcecodeseniorwr.git

echo "Configuring application.properties..."
cat <<EOF > /tmp/sourcecodeseniorwr/src/main/resources/application.properties
jdbc.driverClassName=com.mysql.jdbc.Driver
jdbc.url=jdbc:mysql://mariadb:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=convertToNull
jdbc.username=admin
jdbc.password=admin

memcached.active.host=memcache
memcached.active.port=11211
memcached.standBy.host=memcache
memcached.standBy.port=11211

rabbitmq.address=rabbitmq
rabbitmq.port=5672
rabbitmq.username=test
rabbitmq.password=test

elasticsearch.host=vprosearch01
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

echo "Building application..."
cd /tmp/sourcecodeseniorwr
mvn clean install -DskipTests

echo "Deploying application..."
systemctl stop tomcat
sudo rm -rf $TOMCAT_DIR/webapps/*
cp target/vprofile-v2.war $TOMCAT_DIR/webapps/ROOT.war
chown -R tomcat:tomcat $TOMCAT_DIR/webapps/
systemctl start tomcat

echo "APP01 setup complete."
