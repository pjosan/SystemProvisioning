#!/bin/bash

set -x
set -e 

vbmg() {
    VBoxManage.exe "$@";
}


SED_PROGRAM="/^Config file:/ { s|^Config file: \+\(.\+\)\\\\.\+\.vbox|\1|; s|\\\\|/|gp }"
VM_FOLDER=$(vbmg showvminfo TODO_4640_TEST | sed -ne "$SED_PROGRAM" | tr -d "\r\n")
TODOAPP_VM=TODO_4640_TEST
PXE_VM=PXE4640
SSH_KEY=~/.ssh/acit_admin_id_rsa
NAT=NET_4640

find_machine() {
    local status=$(vbmg list vms | grep "$1" | cut -d'"' -f2)
    if [ -z "$status" ]; then return 1; else return 0; fi
}

find_running_machine() {
    local status=$(vbmg list runningvms | grep "$1" | cut -d'"' -f2)
    if [ -z "$status" ]; then return 1; else return 0; fi
}

cleanup() {
    set +e 

    # Making sure that no VM's are running
    vbmg controlvm $PXE_VM acpipowerbutton
    vbmg controlvm $TODOAPP_VM acpipowerbutton
    vbmg natnetwork remove --netname "$NAT"
    sleep 5
    set -e
}

create_todoapp(){
    echo "Creating $TODOAPP_VM"
    vbmg createvm --name $TODOAPP_VM --ostype RedHat_64 --register

    vbmg modifyvm "TODO_4640_TEST" \
        --memory 4096 \
        --nic1 natnetwork \
        --cpus 2 \
        --nat-network1 "$NAT" \
        --cableconnected1 on \
        --boot1 disk --boot2 net --boot3 none --boot4 none \
        --graphicscontroller vmsvga

    # creates a storage controller inside the VM
    vbmg storagectl "TODO_4640_TEST" --name "SATA" --add sata --controller IntelAHCI

    VM_FOLDER=$(vbmg showvminfo ${TODOAPP_VM} | sed -ne "$SED_PROGRAM" | tr -d "\r\n")
    CONVERT_VM_FOLDER=${VM_FOLDER/C:/\/mnt\/c}


    # creates a storage disk for the VM
    vbmg createmedium disk --filename "$CONVERT_VM_FOLDER"/"$TODOAPP_VM".vdi --size 10240

    # attach the storage disk to the VM
    vbmg storageattach "TODO_4640_TEST" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$CONVERT_VM_FOLDER"/"$TODOAPP_VM".vdi

    vbmg startvm $TODOAPP_VM --type headless
}


create_nat() {

    # Create the NAT Network and configure port forwarding
    vbmg natnetwork add --netname $NAT --enable --dhcp off \
        --network 192.168.150.0/24 \
        --port-forward-4 "PXESSH:tcp:[]:9222:[192.168.150.10]:22" \
        --port-forward-4 "VMHTTP:tcp:[]:8888:[192.168.150.200]:80" \
        --port-forward-4 "TODOSSH:tcp:[]:9223:[192.168.150.200]:22" \

    if find_machine $PXE_VM
    then
        echo "$PXE_VM exists!"

        if find_running_machine $PXE_VM
            then
                echo "$PXE_VM is running!"
                echo "Shutting down $PXE_VM"
                vbmg controlvm PXE4640 acpipowerbutton

    # give extra time for the vm to shutdown
                /bin/sleep 5
                vbmg modifyvm "PXE4640" \
                    --nic1 natnetwork \
                    --nat-network1 $NAT

                # start the PXE after NAT Network configuration
                vbmg startvm $PXE_VM --type headless
            else
                vbmg modifyvm "PXE4640" \
                    --nic1 natnetwork \
                    --nat-network1 $NAT

                # start the PXE after NAT Network configuration
                vbmg startvm $PXE_VM --type headless
            fi
    else
        echo "$PXE_VM does not exist."
        echo "Create first $PXE_VM"
        exit 1
    fi

}

configure_pxe() {
    set +e
    while /bin/true; do
        ssh -i ${SSH_KEY} -p 9222 \
            -q -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            admin@localhost exit
        if [ $? -ne 0 ]; 
        then
            echo "PXE server is not up, sleeping..."
            sleep 5
        else
            scp -i $SSH_KEY -P 9222 -r ./setup admin@localhost:/www
            scp -i $SSH_KEY -P 9222 -r ./acit_admin_id_rsa.pub admin@localhost:/www
            scp -i $SSH_KEY -P 9222 -r ./ks.cfg admin@localhost:/www
            set -e
            break
        fi
    done

    
}

close_pxe() {
    set +e
    while /bin/true; do
        ssh -i ${SSH_KEY} -p 9223 \
            -q -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
            admin@localhost exit
        if [ $? -ne 0 ]; 
        then
            echo "TODOAPP is not up, sleeping..."
            sleep 20
        else
            vbmg controlvm $PXE_VM acpipowerbutton
            set -e
            break
        fi
    done

    
}

main() {

    # Cleanup
    cleanup

    # Provision the Network and start PXE4640
    create_nat

    # Configure PXE4640
    configure_pxe

    
    # Create TODOAPP
    if find_machine $TODOAPP_VM
    then
        echo "$TODOAPP_VM exists!"
        VM_FOLDER=$(vbmg showvminfo ${TODOAPP_VM} | sed -ne "$SED_PROGRAM" | tr -d "\r\n")
        CONVERT_VM_FOLDER=${VM_FOLDER/C:/\/mnt\/c}
        vbmg unregistervm $TODOAPP_VM --delete

        # Call create_todoapp function to create and start the VM
        create_todoapp

    else
        echo "$TODOAPP_VM"
        create_todoapp

    fi

    # Close PXE after use
    close_pxe
}



main

