#!/bin/bash
sudo useradd todoapp
sudo su todoapp -c "chmod a+rwx ~"
sudo dnf install -y git
sudo su todoapp -c "git clone https://github.com/timoguic/ACIT4640-todo-app.git ~/app"
sudo su todoapp -c "chmod -R a+rwx ~"
sudo dnf search nodejs
sudo dnf install -y nodejs
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash - 
sudo dnf search mongod
sudo touch /etc/yum.repos.d/mongodb-org-4.4.repo
sudo cp setup/mongodb-org-4.4.repo /etc/yum.repos.d/mongodb-org-r.r.repo
sudo dnf install -y mongodb-org
sudo runuser -l todoapp -c 'sed -i -e 's/CHANGEME/acit4640/g' /home/todoapp/app/config/database.js'
sudo systemctl start mongod
sudo su todoapp -c "cd ~/app && npm install"
sudo cp setup/selinux_config /etc/selinux/config
sudo setenforce 0
sudo firewall-cmd --zone=public --add-port=8080/tcp
sudo firewall-cmd --runtime-to-permanent
sudo firewall-cmd --zone=public --add-service=http
sudo firewall-cmd --runtime-to-permanent
sudo cd /etc/systemd/system/
sudo touch /etc/systemd/system/todoapp.service
sudo cp setup/todoapp.service /etc/systemd/system/todoapp.service
sudo systemctl daemon-reload
sudo systemctl enable todoapp
sudo systemctl start todoapp
sudo dnf install -y epel-release
sudo dnf install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx 
sudo cp setup/nginx.conf /etc/nginx/nginx.conf
sudo systemctl restart nginx


