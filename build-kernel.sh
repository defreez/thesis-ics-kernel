#!/bin/sh
#
# Based on emulator build-kernel.sh

OUTPUT=/tmp/kernel-ics
CROSSPREFIX=arm-eabi-
CONFIG=thesis

HOST_OS=linux
HOST_TAG=linux-x86
BUILD_NUM_CPUS=$(grep -c processor /proc/cpuinfo)

# Default number of parallel jobs during the build: cores * 2
JOBS=$(( $BUILD_NUM_CPUS * 2 ))

ARCH=arm

mkdir -p $OUTPUT

CROSSTOOLCHAIN=arm-eabi-4.4.3
CROSSPREFIX=arm-eabi-
ZIMAGE=zImage

# If the cross-compiler is not in the path, try to find it automatically
CROSS_COMPILER="${CROSSPREFIX}gcc"
CROSS_COMPILER_VERSION=$($CROSS_COMPILER --version 2>/dev/null)
if [ $? != 0 ] ; then
BUILD_TOP=$ANDROID_BUILD_TOP
    if [ -z "$BUILD_TOP" ]; then
        # Assume this script is under a kernel directory in root
        # Android source tree.
        BUILD_TOP=$(dirname $0)/..
        if [ ! -d "$BUILD_TOP/prebuilt" ]; then
BUILD_TOP=
        else
BUILD_TOP=$(cd $BUILD_TOP && pwd)
        fi
fi
CROSSPREFIX=$BUILD_TOP/prebuilt/$HOST_TAG/toolchain/$CROSSTOOLCHAIN/bin/$CROSSPREFIX
    if [ "$BUILD_TOP" -a -f ${CROSSPREFIX}gcc ]; then
echo "Auto-config: --cross=$CROSSPREFIX"
    else
echo "It looks like $CROSS_COMPILER is not in your path ! Aborting."
        exit 1
    fi
fi

export CROSS_COMPILE="$CROSSPREFIX" ARCH SUBARCH=$ARCH

# Do the build
#
rm -f include/asm &&
make ${CONFIG}_defconfig && # configure the kernel
make -j$JOBS # build it

if [ $? != 0 ] ; then
echo "Could not build the kernel. Aborting !"
    exit 1
fi

OUTPUT_KERNEL=kernel-$CONFIG

cp -f arch/$ARCH/boot/$ZIMAGE $OUTPUT/$OUTPUT_KERNEL

echo "Kernel $CONFIG prebuilt image ($OUTPUT_KERNEL) copied to $OUTPUT successfully !"
exit 0
