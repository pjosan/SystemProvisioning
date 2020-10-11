#!/bin/bash

TODOAPP_HOME=/home/todoapp
ADMIN_HOME=/home/admin
set -x

# Moving system files
sudo mv $ADMIN_HOME/setup/todoapp.service /etc/systemd/system


# Disable selinux
sudo setenforce 0
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config

# Install EPEL & NGINX
dnf install -y epel-release
dnf install -y nginx


# Add Firewall rule 
# sudo firewall-cmd --zone=public --add-port=8080/tcp
sudo firewall-offline-cmd --zone=public --add-service=http
sudo firewall-offline-cmd --runtime-to-permanent

# Install git
dnf install -y git


# Create another user for the application
useradd todoapp
su - todoapp -c "chmod a+rx $TODOAPP_HOME"


# Download the app repository
su - todoapp -c "git clone https://github.com/timoguic/ACIT4640-todo-app.git $TODOAPP_HOME/app"

# Update the database.js file
su - todoapp -c "sed -i 's/CHANGEME/acit4640/g' $TODOAPP_HOME/app/config/database.js"

# Install Node
curl -sL https://rpm.nodesource.com/setup_12.x | sudo bash -

sudo dnf install -y nodejs

# Install Mongo
sudo mv $ADMIN_HOME/setup/mongodb-org-4.4.repo /etc/yum.repos.d/
sudo dnf install -y mongodb-org  
sudo systemctl start mongod

# Downloading the application dependencies
sudo npm install --folder $TODOAPP_HOME/app/

# Reload and enable todoapp service
sudo systemctl daemon-reload
sudo systemctl enable todoapp


# Configure NGINX
sudo mv $ADMIN_HOME/setup/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl start todoapp
