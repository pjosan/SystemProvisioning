Vagrant.configure("2") do |config|
  config.vm.box = "4640BOX"
  config.ssh.username = "admin"
  config.ssh.private_key_path = "acit_admin_id_rsa"
  
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
    
  end

  config.vm.provision "file", source: ".ansible", destination: "/home/admin/ansible"

  config.vm.define "tododb" do |tododb|
    tododb.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_DB_4640"
        vb.memory = 1536
        
        
  
    end
    tododb.vm.hostname = "tododb.bcit.local"
    tododb.vm.network "private_network", ip: "192.168.150.20"
    tododb.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "home/admin/ansible"
      ansible.playbook = "/home/admin/ansible/db.yaml"
    end
  end

  config.vm.define "todoproxy" do |todoproxy|
    todoproxy.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_PROXY_4640"
        vb.memory = 2048
        
        
  
    end
    todoproxy.vm.hostname = "todoproxy.bcit.local"
    todoproxy.vm.network "private_network", ip: "192.168.150.30"
    todoproxy.vm.network "forwarded_port", guest: 80, host: 8888
    todoproxy.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/home/admin/ansible"
      ansible.playbook = "/home/admin/ansible/nginx.yaml"
    end


  end

  config.vm.define "todoapp" do |todoapp|
    todoapp.vm.provider "virtualbox" do |vb|
        vb.name = "TODO_APP_4640"
        vb.memory = 2048
       
       
        
    end
    todoapp.vm.hostname = "todoapp.bcit.local"
    todoapp.vm.network "private_network", ip: "192.168.150.10"
    todoapp.vm.provision "ansible_local" do |ansible|
      ansible.provisioning_path = "/home/admin/ansible"
      ansible.playbook = "/home/admin/ansible/app.yaml"
    end
  end
  

  
end
