#!/bin/bash -x
USER_NAME=todoapp
sudo useradd $USER_NAME
USER_FOLDER=/app
sudo mkdir $USER_FOLDER
sudo su todoapp -c "cd $USER_FOLDER"
