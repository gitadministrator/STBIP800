# build_general.sh
#
# This is the generic part of the script used for building boot images
# for the Motorola VIP.
#
# Further information about how to build a boot image can be found in
# the development kit manual, section "Develop for the Motorola VIP
# -> Boot image -> Building".
#
# Copyright (c) 2007-2010 Motorola, Inc. All rights reserved.
# Copyright (c) 2011-2012 Motorola Mobility, Inc. All rights reserved.
#
# This program is confidential and proprietary to Motorola Mobility, Inc and
# may not be copied, reproduced, disclosed to others, published or used, in
# whole or in part, without the expressed prior written permission of Motorola
# Mobility, Inc.

set -e

if [ -z "${VIP_NAME}" ]; then
    echo "The environment is not set up properly"
    echo "This script should not be used directly, use build_vip19x3.sh"
    echo "for example to build for the VIP19X3"
    exit 1
fi

if [ -z "${1}" ]; then
    echo "Usage: ${0} <config file> [minor version]"
    exit 1
fi

if ! [ -r "${1}" ]; then
    echo "${0}: Error: Cannot read configuration file ${1}"
    exit 1
fi

config_file=$1
minor_version=$2
firmware=$2

### Paths

# These directories may have to be modified to correspond to your
# installation. 

#script_dir=$(dirname $0)

#export CONFIG_DIR=$(dirname $(readlink -m "$config_file"))
export CONFIG_DIR=${EASL_SDK_ROOT}/build_scripts

# This should be the path to the directory where your development kit
# (xDK) is unpacked.

dk_dir=${EASL_SDK_ROOT}
dist_dir=${dk_dir}/dist

# This is the path to the location where the boot image will be built.

bi_dir=$(pwd)/bi
#iip_dir=$(pwd)/directfb-example/example-app-directfb-example_DEV-opera-dfb_bcm45_ip800.iip
iip_dir=$(pwd)/directfb-example/*.iip

### Create the output directory if necessary

if [ ! -d "${bi_dir}" ]
then
    echo "Creating output directory \"${bi_dir}\""
    mkdir -p ${bi_dir}
fi


### Set up build_boot_image parameters

products_dk=${dk_dir}/products

supported_dk_list="kbk hdk motomotodk sdk"
dk_type=$(sed -n -e 's/\s*<Type>\(.*\)<\/Type>/\1/p' ${dist_dir}/dk.xml)
xml_dir=${dist_dir}

for dk in $supported_dk_list; do
    if [ "${dk_type}" == "$dk" ]; then
        supported="ok"
        break
    fi
done

if [ -z "$supported" ]; then
    echo "Error: Unsupported dk"
    exit 1
fi

version=$(cat ${xml_dir}/build_data.xml \
    | grep Version \
    | cut -f 2 -d '>' \
    | cut -f 1 -d '<')${minor_version:+_$minor_version}

if [ "${dk}" = "kbk" -o "${dk}" = "hdk" -o "${VIP_NAME}" = "host_host" ]; then
    internal_use_only="_INTERNAL-USE-ONLY"
fi

### Build boot image and root disk, send log to build_log

# Check the development kit manual in the section
# Reference->Tools/Commands->build_boot_image for
# information on these options.

base_name=${config_file##*/}${internal_use_only}_${version}_${VIP_NAME}
bi_name=kreatv-bi-${base_name}
bi_file=${bi_dir}/${bi_name}.bin
txt_file=${bi_dir}/${bi_name}.txt
rootdisk_file=${bi_dir}/kreatv-rootdisk-${base_name}.tgz
kernel_file=${bi_dir}/kreatv-kernel-nfs-${base_name}

builddate=$(date +%Y%m%d)
buildtime=$(date +%H%M%S)

# Remove an older bootimage in case this build should fail.
rm -f ${bi_file} ${txt_file}

# Setup Perl module search path
export PERLLIB=${dist_dir}/bin

if [ -d ${dist_dir}/${VIP_NAME%%_*}/3pp/${VIP_NAME##*_}/bin ]; then
    source_bin_dir_3pp="--source ${dist_dir}/${VIP_NAME%%_*}/3pp/${VIP_NAME##*_}/bin"
elif [ -d ${dist_dir}/${VIP_NAME%%_*}/3pp/bin ]; then
    source_bin_dir_3pp="--source ${dist_dir}/${VIP_NAME%%_*}/3pp/bin"
fi

${dist_dir}/bin/build_boot_image \
      --toolchain $(cat ${dist_dir}/${VIP_NAME%%_*}/toolchain_dir) \
      ${source_bin_dir_3pp} \
      --iip ${iip_dir} \
      --source ${products_dk} \
      --boot_image ${bi_file} \
      --rootdisk ${rootdisk_file} \
      --kernel ${kernel_file} \
      --architecture ${VIP_NAME} \
      --config ${config_file} \
      --info version ${version} \
      --info configuration ${config_file##*/} \
      --info company "Motorola, Inc." \
      --info date ${builddate} \
      --info time ${buildtime} \
      2>&1 | tee build_log
build_result=$?
if [ ! $build_result ]
then
    exit $build_result
fi

echo

if [ ! -s "${bi_file}" ]
then
    echo "Error: the build failed"
    exit 1
fi

### Write the configuration to a text file with the
### same name as the boot image. Keep this for reference.

echo "# Configuration for ${bi_name}.bin" >${txt_file}
echo "# Boot image md5 sum:" $(md5sum ${bi_file} | cut -d" " -f1) >>${txt_file}
echo "# Build date: $builddate  Build time: $buildtime" >>${txt_file}
cat ${config_file} >>${txt_file}

echo "Done"
echo "The boot image is ${bi_file}"
echo "The configuration is ${txt_file}"
