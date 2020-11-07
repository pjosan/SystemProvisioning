#!/bin/bash

APP="/home/todoapp/app"
REPO_URL="https://github.com/timoguic/ACIT4640-todo-app.git"

git clone $REPO_URL $APP
npm install --prefix $APP
sed -i -e 's/CHANGEME/acit4640/' "${APP}/config/database.js"
chmod a+rx /home/todoapp