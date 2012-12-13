#Set only one value for the toolchain and the SDK - the last override wins !

set -e 

if [ -z "${1}"  ]; then
if [ -z "${2}" ]; then
	echo "Usage: source ./ip800_buildenv.sh [toolchain version] [sdk version] "
	echo "Setting  TOOLCHAIN/SDK VERSION to the Latest Version Avilable"
	#export EASL_TOOLCHAIN_VER='1.0.3'
	export EASL_TOOLCHAIN_VER='2.0.0'
	#export EASL_SDK_VER='264075'
	export EASL_SDK_VER='275437'
fi

elif [ -z "${2}" ]; then
	echo "Usage: source ./ip800_buildenv.sh [toolchain version] [sdk version] "
        echo "Setting  TOOLCHAIN/SDK VERSION to the Latest Version Avilable"
        #export EASL_TOOLCHAIN_VER='1.0.3'
        export EASL_TOOLCHAIN_VER='2.0.0'
        #export EASL_SDK_VER='264075'
        export EASL_SDK_VER='275437'
else
	toolchain_version=$1
	sdk_version=$2
	export EASL_TOOLCHAIN_VER=${toolchain_version}
	export EASL_SDK_VER=${sdk_version}
fi

#####################################################################################
# DO NOT EDIT BELOW THIS LINE. ITS SELF GENERATING CODE.
# ALSO ITS MAINTAINED BY  THE SCM/BUILD ADMIN OF THIS PROJECT.
#####################################################################################

echo "Toolchain version: ${EASL_TOOLCHAIN_VER}"
echo "SDK: ${EASL_SDK_VER}"

if [ ! -d "/usr/local/motorola/toolchain/bcm45/${EASL_TOOLCHAIN_VER}" ]; then
        echo "ToolChain Version Entered Doesn't Exists"
elif [ ! -d "/opt/motorola/sdk_${EASL_TOOLCHAIN_VER}_${EASL_SDK_VER}" ]; then
	 echo "SDK Version Entered Doesn't Exists"
else

#Toolchain Versioning and management
export EASL_TOOLCHAIN_CHIPSET='bcm45'
export EASL_VIP="${EASL_TOOLCHAIN_CHIPSET}"
export EASL_HW="ip800"
export EASL_TOOLCHAIN_TRIPLET='mipsel-motorola-linux-uclibc'
export EASL_TOOLCHAIN_ROOT="/usr/local/motorola/toolchain/${EASL_TOOLCHAIN_CHIPSET}/${EASL_TOOLCHAIN_VER}/"
export EASL_TOOLCHAIN_BINPATH="${EASL_TOOLCHAIN_ROOT}/bin/"

case ${EASL_TOOLCHAIN_VER} in
    "1.0.3")
	# Set CFLAGS, CXXFLAGS and LDFLAGS
	export EASL_TOOLCHAIN_CFLAGS=" -I. -I${EASL_TOOLCHAIN_ROOT}/sys-root/usr/include -g -Os -D_${EASL_TOOLCHAIN_CHIPSET}_=1 -fPIC "
	export EASL_TOOLCHAIN_CXXFLAGS=" -I. -I${EASL_TOOLCHAIN_ROOT}/sys-root/usr/include -g -Os -D_${EASL_TOOLCHAIN_CHIPSET}_=1 -fPIC "
	export EASL_TOOLCHAIN_LDFLAGS=" -lm -L${EASL_TOOLCHAIN_ROOT}/lib -L${EASL_TOOLCHAIN_ROOT}/sys-root/lib -L${EASL_TOOLCHAIN_ROOT}/sys-root/usr/lib "
	;;

#This setting should work for toolchain 2.0.0 onwards 
    *)
	# Set CFLAGS, CXXFLAGS and LDFLAGS
	export EASL_TOOLCHAIN_CFLAGS=" -I. -I${EASL_TOOLCHAIN_ROOT}/${EASL_TOOLCHAIN_TRIPLET}/sys-root/usr/include -g -Os -D_${EASL_TOOLCHAIN_CHIPSET}_=1 -fPIC "
	export EASL_TOOLCHAIN_CXXFLAGS=" -I. -I${EASL_TOOLCHAIN_ROOT}/${EASL_TOOLCHAIN_TRIPLET}/sys-root/usr/include -g -Os -D_${EASL_TOOLCHAIN_CHIPSET}_=1 -fPIC "
	export EASL_TOOLCHAIN_LDFLAGS=" -lm -L${EASL_TOOLCHAIN_ROOT}/lib -L${EASL_TOOLCHAIN_ROOT}/${EASL_TOOLCHAIN_TRIPLET}/sys-root/lib -L${EASL_TOOLCHAIN_ROOT}/${EASL_TOOLCHAIN_TRIPLET}/sys-root/usr/lib "
	;;
esac

#SDK Versioning and management
export EASL_SDK_ROOT="/opt/motorola/sdk_${EASL_TOOLCHAIN_VER}_${EASL_SDK_VER}/"
export DK_DIR=${EASL_SDK_ROOT}

case ${EASL_SDK_VER} in
    "264075")
	# Set CFLAGS, CXXFLAGS and LDFLAGS
	export EASL_SDK_CFLAGS=" -I${EASL_SDK_ROOT}/${EASL_TOOLCHAIN_CHIPSET}/include -I${EASL_SDK_ROOT}/${EASL_TOOLCHAIN_CHIPSET}/3pp/include "
	export EASL_SDK_CXXFLAGS=" -I${EASL_SDK_ROOT}/${EASL_TOOLCHAIN_CHIPSET}/include -I${EASL_SDK_ROOT}/${EASL_TOOLCHAIN_CHIPSET}/3pp/include "
	export EASL_SDK_LDFLAGS=" -L${EASL_SDK_ROOT}/lib -L${EASL_SDK_ROOT}/${EASL_TOOLCHAIN_CHIPSET}/3pp/lib "
	;;

#This setting should work SDK build 275437 onwards 
    *)
	# Set CFLAGS, CXXFLAGS and LDFLAGS
	export EASL_SDK_CFLAGS=" -I${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/include -I${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/3pp/include "
	export EASL_SDK_CXXFLAGS=" -I${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/include -I${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/3pp/include "
	export EASL_SDK_LDFLAGS=" -L${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/lib -L${EASL_SDK_ROOT}/dist/${EASL_TOOLCHAIN_CHIPSET}/3pp/lib "
	;;
esac


#Compiler configs and variables
export CC=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-gcc
export AS=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-as
export AR=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-ar
export NM=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-nm
export RANLIB=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-ranlib
export STRIP=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-strip
export SIZE=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-size
export LD=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-ld
export CXX=${EASL_TOOLCHAIN_BINPATH}/${EASL_TOOLCHAIN_TRIPLET}-c++

export CFLAGS="${EASL_TOOLCHAIN_CFLAGS} ${EASL_SDK_CFLAGS}"
export CXXFLAGS="${EASL_TOOLCHAIN_CXXFLAGS} ${EASL_SDK_CXXFLAGS}"
export LDFLAGS="${EASL_TOOLCHAIN_LDFLAGS} ${EASL_SDK_LDFLAGS}" 

fi
