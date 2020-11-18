#!/bin/bash

# Variables
TODOAPP_USER=todoapp
APP_FOLDER=app
DEST_FOLDER=/home/$TODOAPP_USER/$APP_FOLDER

# Create users
useradd admin
usermod -aG wheel admin
useradd todoapp

# Passwordless sudo
sudo sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# Setup SSH
mkdir /home/admin/.ssh/
cat setup/acit_admin_id_rsa.pub > /home/admin/.ssh/authorized_keys

# Unzip Todoapp Directory

tar zxvf setup/app.tar.gz -C /home/$TODOAPP_USER

# Node and MongoDB Dependencies
sudo curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
sudo dnf install nodejs -y
sudo cp setup/mongodb-org-4.4.repo /etc/yum.repos.d/mongodb-org-4.4.repo
sudo dnf install -y mongodb-org

# Node and MongoDB Setup
sudo cp setup/database.js $DEST_FOLDER/config/database.js
sudo chmod 777 $DEST_FOLDER/config/database.js
sudo systemctl enable mongod

# Change Todoapp Home Directory Permissions
sudo chmod 755 /home/${TODOAPP_USER}

# Todoapp Service
cp setup/todoapp.service /etc/systemd/system/todoapp.service
sudo systemctl daemon-reload
sudo systemctl enable todoapp

# Nginx Service
sudo dnf install -y epel-release
sudo dnf install -y nginx
sudo cp setup/nginx.conf /etc/nginx/nginx.conf
sudo systemctl enable nginx