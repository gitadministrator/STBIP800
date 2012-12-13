#!/bin/bash

set -e

#set the environment and compilation flags for th build
#argument1 - Toolchain Version
#argument2 - Sdk Version
source $(pwd)/ip800_buildenv.sh ${1} ${2}

#building the Application - Directfb-Example and generate the application iip
cd directfb-example/
make clean VIP=bcm45 HW=ip800
make VIP=bcm45 HW=ip800

#copying the iip file to $SDK/products/
#cp *.iip /opt/motorolla/sdk/products/

#Edit the build configuration file to add application name
#TBD

cd ..

# Build boot image for Motorola IP800
export VIP_NAME=bcm45_ip800
source $(pwd)/build_general.sh ip800_bcm45.config

#Install boot image using TFTP+NFS
export user=$(whoami)
echo $user
sudo rm -rf /var/lib/tftpboot/ip800/$user/vmlinuz.pkg
sudo rm -rf /exports/ip800/$user/rootdisk
cp bi/kreatv-kernel-nfs-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.pkg  /var/lib/tftpboot/ip800/$user/vmlinuz.pkg
#tar xzf bi/kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz -C /exports/ip800/$user/rootdisk
cp  bi/kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz /exports/ip800/$user/
cd /exports/ip800/$user/
sudo tar -xvzf kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz rootdisk
