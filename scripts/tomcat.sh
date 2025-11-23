#!/bin/bash
set -e

echo "=== Provisioning VM: $(hostname) ==="

if [ -f /etc/os-release ]; then
    . /etc/os-release

######################################################################
# Ubuntu / Debian
######################################################################
if [[ "$ID" = "ubuntu" || "$ID" = "debian" ]]; then

    echo "-- Installing packages --"
    apt update
    apt install -y curl wget tree vim htop tmux git net-tools fontconfig openjdk-17-jre openjdk-17-jdk maven

    echo "-- Creating tomcat user --"
    useradd -m -U -d /usr/local/tomcat -s /bin/false tomcat || true

    echo "-- Downloading Tomcat --"
    mkdir -p /opt/apache/
    cd /opt/apache/
    wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
    tar xvf apache-tomcat-9.0.112.tar.gz

    CATALINA_HOME=/opt/apache/apache-tomcat-9.0.112

    echo "-- Setting Tomcat permissions --"
    chown -R tomcat:tomcat $CATALINA_HOME
    chmod +x $CATALINA_HOME/bin/*.sh

    echo "-- Cloning & building app --"
    cd /opt/
    git clone https://github.com/kareemloulah/MicroService-App-Deployment.git
    cd MicroService-App-Deployment
    mvn clean install -DskipTests

    echo "-- Deploying WAR --"
    cp target/vprofile-v2.war $CATALINA_HOME/webapps/

    ##################################################################
    # Edit Tomcat configuration files
    ##################################################################
    echo "-- Editing Tomcat configuration (users + manager access) --"

    # tomcat-users.xml
    cat <<EOF >"$CATALINA_HOME/conf/tomcat-users.xml"
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="admin" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOF

    # Remove access restriction from manager app
    sed -i 's/<Valve.*RemoteAddrValve.*>//g' \
        $CATALINA_HOME/webapps/manager/META-INF/context.xml || true

    sed -i 's/<Valve.*RemoteAddrValve.*>//g' \
        $CATALINA_HOME/webapps/host-manager/META-INF/context.xml || true

    ##################################################################
    # Create systemd service for Tomcat
    ##################################################################
    echo "-- Creating Tomcat service --"
    cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
Group=tomcat
WorkingDirectory=$CATALINA_HOME
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


######################################################################
# CentOS / Fedora
######################################################################
elif [[ "$ID" = "centos" || "$ID" = "fedora" ]]; then

    echo "-- Installing packages --"
    dnf update -y
    dnf install -y curl wget vim htop tmux git net-tools java-17-openjdk java-17-openjdk-devel maven firewalld

    echo "-- Downloading Tomcat --"
    cd /tmp/
    wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.112/bin/apache-tomcat-9.0.112.tar.gz
    tar -xvzf apache-tomcat-9.0.112.tar.gz

    echo "-- Creating tomcat user --"
    useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat || true

    echo "-- Installing Tomcat --"
    mkdir -p /usr/local/tomcat
    cp -r /tmp/apache-tomcat-9.0.112/* /usr/local/tomcat/
    chown -R tomcat:tomcat /usr/local/tomcat
    chmod +x /usr/local/tomcat/bin/*.sh

    TOMCAT_DIR=/usr/local/tomcat

    ###################################################
    # Edit conf/tomcat-users.xml (Add admin user)
    ###################################################
    cat <<EOF >"$TOMCAT_DIR/conf/tomcat-users.xml"
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users>
    <role rolename="manager-gui"/>
    <role rolename="admin-gui"/>
    <user username="admin" password="admin" roles="manager-gui,admin-gui"/>
</tomcat-users>
EOF

    ###################################################################
    # Edit manager/META-INF/context.xml (Allow remote manager access)
    ###################################################################
    sed -i 's/<Valve.*RemoteAddrValve.*>//g' \
        $TOMCAT_DIR/webapps/manager/META-INF/context.xml || true

    sed -i 's/<Valve.*RemoteAddrValve.*>//g' \
        $TOMCAT_DIR/webapps/host-manager/META-INF/context.xml || true

    echo "-- Creating systemd service --"
    cat <<EOF >/etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
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
RestartSec=10
Restart=always

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
fi

echo "=== Provisioning complete ==="
