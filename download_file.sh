#!/bin/bash
sudo useradd todoapp
MONGO_DB_NAME=acit4640
curl -sL https://raw.githubusercontent.com/timoguic/ACIT4640-todo-app/master/config/database.js | sudo bash - 
sudo sed "s/CHANGEME/${MONGO_DB_NAME}/g" database.js >> download.txt
