#!/bin/bash

set -e

# source the compiler flags, ToolChain,SDK directory Paths
# input1 - Toolchain Version
# input2 - Sdk Version
source $(pwd)/ip800_buildenv.sh ${1} ${2}

# Build the Application : Create Executable and IIP
# IIP consists of application executable, properties file, and installation 
# Makefile parameters specify the processor type and platform typescript

#Building the EmbeddedApp
#cd ../EmbeddedApp/
#make clean VIP=bcm45 HW=ip800
#make VIP=bcm45 HW=ip800

#Building the NPAPIPlugin
#cd ../NPAPIPlugin/
#make clean VIP=bcm45 HW=ip800
#make VIP=bcm45 HW=ip800

cd ../EmbeddedApp/
make clean VIP=bcm45 HW=ip800
make VIP=bcm45 HW=ip800
cd ..

#cd ../build/

# Build boot image for Motorola IP800
export VIP_NAME=bcm45_ip800
source $(pwd)/build_general.sh ip800_bcm45.config

#Install boot image using TFTP+NFS

export user=$(whoami)
echo $user

rm -rf /var/lib/tftpboot/ip800/$user/vmlinuz.pkg
cp bi/kreatv-kernel-nfs-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.pkg  /var/lib/tftpboot/ip800/$user/vmlinuz.pkg

# Root privileges required while running 'tar' otherwise nodes are not created
sudo -i
rm -rf /exports/ip800/$user/rootdisk
tar xzf bi/kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz -C /exports/ip800/$user/rootdisk

#cp  bi/kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz /exports/ip800/$user/
#cd /exports/ip800/$user/
#sudo tar -xvzf kreatv-rootdisk-ip800_bcm45.config_KA13.01.02.00Birch.275437_bcm45_ip800.tgz rootdisk
