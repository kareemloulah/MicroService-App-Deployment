#!/bin/bash
set -e
echo "=== Provisioning VM: $(hostname) ==="
########################################################################
# Ubuntu / Debian
########################################################################
if [ -f /etc/os-release ]; then
  . /etc/os-release

  if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
    echo "-- Installing packages --"
    sudo apt update
    sudo apt install -y curl wget tree vim htop tmux git net-tools nginx

    echo "-- Configuring Nginx reverse proxy to Tomcat --"
    sudo tee /etc/nginx/sites-available/tomcat.conf >/dev/null <<EOF
server {
    listen 80;

    location / {
        proxy_pass http://tomcat:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo ln -sf /etc/nginx/sites-available/tomcat.conf /etc/nginx/sites-enabled/
    sudo nginx -t
    sudo systemctl restart nginx
    sudo systemctl enable nginx



########################################################################
# CentOS / Fedora
########################################################################

  elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ]; then
    echo "-- Installing packages --"
    sudo yum update -y -q
    sudo yum install -y -q curl wget vim htop tmux git net-tools nginx

    echo "-- Configuring Nginx reverse proxy to Tomcat --"
    sudo tee /etc/nginx/conf.d/tomcat.conf >/dev/null <<EOF
server {
    listen 80;

    location / {
        proxy_pass http://tomcat:8080/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    sudo nginx -t
    sudo systemctl restart nginx
    sudo systemctl enable nginx
  fi
fi

echo "=== Provisioning complete ==="
