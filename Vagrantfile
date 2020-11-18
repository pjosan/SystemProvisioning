Vagrant.configure("2") do |config|
  config.vm.box = "4640BOX"
  config.ssh.username = "admin"
  config.ssh.private_key_path = "acit_admin_id_rsa"
  
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    
  end

  

  config.vm.define "tododb" do |tododb|
    tododb.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_DB_4640"
        vb.memory = 1536
        
        
  
    end
    tododb.vm.hostname = "tododb.bcit.local"
    tododb.vm.network "private_network", ip: "192.168.150.20"
    tododb.vm.provision "file", source: "files/mongodb-org-4.4.repo", destination: "/tmp/mongodb-org-4.4.repo"
    tododb.vm.provision "file", source: "files/mongodb_ACIT4640.tgz", destination: "/tmp/mongodb_ACIT4640.tgz"
    tododb.vm.provision "shell", inline: <<-SHELL
    mv /tmp/mongodb-org-4.4.repo /etc/yum.repos.d/mongodb-org-4.4.repo  
    dnf install -y mongodb-org wget curl tar
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    dnf whatprovides mongorestore
    
    mv /tmp/mongodb_ACIT4640.tgz .

    tar zxvf mongodb_ACIT4640.tgz
    export LANG=C.

    sudo sed -r -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
    sudo firewall-cmd --zone=public --add-port=27017/tcp
    sudo firewall-cmd --runtime-to-permanent

    systemctl daemon-reload
    
    systemctl start mongod
 

    systemctl enable mongod

    mongorestore -d acit4640 ACIT4640
    
    SHELL
    # Do other machine-specific provisioning here
  end

  config.vm.define "todoproxy" do |todoproxy|
    todoproxy.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_PROXY_4640"
        vb.memory = 2048
        
        
  
    end
    todoproxy.vm.hostname = "todoproxy.bcit.local"
    todoproxy.vm.network "private_network", ip: "192.168.150.30"
    todoproxy.vm.network "forwarded_port", guest: 80, host: 8888
    todoproxy.vm.provision "file", source: "files/nginx.conf", destination: "/tmp/nginx.conf"
    todoproxy.vm.provision "shell", inline: <<-SHELL
  
    dnf install -y git nginx 
    mv /tmp/nginx.conf /etc/nginx/nginx.conf
    
    sudo firewall-cmd --zone=public --add-port=80/tcp
    sudo firewall-cmd --runtime-to-permanent

    systemctl daemon-reload
    systemctl enable nginx
    systemctl start nginx
    SHELL
    # Do other machine-specific provisioning here
  end

  config.vm.define "todoapp" do |todoapp|
    todoapp.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_APP_4640"
        vb.memory = 2048
       
       
        
    end
    todoapp.vm.hostname = "todoapp.bcit.local"
    todoapp.vm.network "private_network", ip: "192.168.150.10"
    todoapp.vm.provision "file", source: "files/todoapp.service", destination: "/tmp/todoapp.service"
    todoapp.vm.provision "file", source: "files/install_script.sh", destination: "/tmp/install_script.sh"
    todoapp.vm.provision "file", source: "files/database.js", destination: "/tmp/database.js"
    todoapp.vm.provision "shell", inline: <<-SHELL
    curl -sL https://rpm.nodesource.com/setup_14.x | bash -
    dnf install -y git nodejs
    useradd todoapp
    sudo -u todoapp bash /tmp/install_script.sh
   

    sudo firewall-cmd --zone=public --add-port=8080/tcp
    sudo firewall-cmd --runtime-to-permanent

    mv /tmp/database.js /home/todoapp/app/config/database.js
    mv /tmp/todoapp.service /etc/systemd/system/todoapp.service
    

    systemctl daemon-reload
    systemctl enable todoapp
    systemctl start todoapp
    
    SHELL
    # Do other machine-specific provisioning here
  end

  

  
end
