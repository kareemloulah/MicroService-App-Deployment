# MicroService App Deployment

A comprehensive microservice application deployment setup using Vagrant and multiple backend services.

## Overview

This project demonstrates a multi-tier microservice architecture with the following components:

- **Nginx** - Reverse proxy and load balancer (192.168.56.11)
- **Tomcat** - Application server (192.168.56.12)
- **Memcache** - Caching layer (192.168.56.13)
- **RabbitMQ** - Message broker (192.168.56.14)
- **MariaDB** - Database (192.168.56.15)

## Prerequisites

- **Vagrant** - Infrastructure as Code provisioning tool
- **Hyper-V** or **Libvirt** - Virtualization platform
- **Git** - Version control

## Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd MicroService-App-Deployment
```

### 2. Start Virtual Machines
```bash
vagrant up --provision --no-parallel
```

### 3. Access Services
- **Application**: http://192.168.56.11 (Nginx)
- **Tomcat**: http://192.168.56.12:8080
- **RabbitMQ Management**: http://192.168.56.14:15672
- **Database**: mariadb:3306

## Project Structure

```
├── Vagrantfile              # Vagrant configuration (Hyper-V & Libvirt)
├── scripts/                 # Provisioning scripts
│   ├── mariadb.sh
│   ├── rabbitmq.sh
│   ├── memcache.sh
│   ├── tomcat.sh
│   └── nginx.sh
├── src/                     # Application source code
│   ├── main/
│   │   ├── java/            # Java application code
│   │   ├── resources/       # Configuration files
│   │   └── webapp/          # Web resources (JSP, CSS, JS)
│   └── test/                # Unit tests
└── pom.xml
└── README.md
```

## Technology Stack

- **Backend**: Java, Spring Framework
- **Web Server**: Nginx, Apache Tomcat
- **Database**: MariaDB
- **Message Queue**: RabbitMQ
- **Cache**: Memcached
- **Search**: Elasticsearch
- **Testing**: JUnit

## Configuration

### Hyper-V (Default)
The Vagrantfile uses Hyper-V by default. VMs are configured with:
- **Memory**: 1536 MB (max 2048 MB)
- **CPU**: 1 core
- **Network**: Private static IP + Public DHCP bridge

### Libvirt (Alternative)
Uncomment the Libvirt section in the Vagrantfile to use KVM/Libvirt instead.

## Common Commands

```bash
# Start all VMs
vagrant up --no-parallel

# Stop all VMs
vagrant halt

# Restart all VMs
vagrant reload

# View VM status
vagrant status

# SSH into a specific VM
vagrant ssh <vm-name>

# Destroy all VMs
vagrant destroy
```

## Features

- User authentication and authorization
- File upload functionality
- Elasticsearch integration
- Message queue processing (Producer/Consumer)
- Caching with Memcached
- Responsive UI with Bootstrap

## Development

### Building the Application
```bash
mvn clean install
```

### Running Tests
```bash
mvn test
```

### Deploying to Tomcat
Deploy the WAR file to the Tomcat VM at `192.168.56.12`.

## Troubleshooting

- **VMs fail to start**: Ensure Hyper-V/Libvirt is enabled on your system
- **Network connectivity issues**: Verify the Default Switch (Hyper-V) or bridge network (Libvirt)
- **Provision script errors**: Check individual script logs in `/var/log`