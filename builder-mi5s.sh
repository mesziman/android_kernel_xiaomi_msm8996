#!/bin/bash

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel2
CCACHEDIR=../CCACHE/capricorn
TOOLCHAINDIR=/pipeline/build/root/toolchain/aarch64-linux-android-4.9/bin
TOOLCHAIN32=/pipeline/build/root/toolchain/arm-linux-androideabi-4.9/bin
DATE=$(date +"%d%m%Y")
KERNEL_NAME="Syberia"
DEVICE="-capricorn-"
VER="-0.1"
TYPE="PIE-EAS"
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$DATE""$TYPE""$VER".zip

rm $ANYKERNEL_DIR/capricorn/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
git reset --hard ebf55267949deb856f246a9c97053b8fd26b3cef && git cherry-pick c7e9b175fefdc943a20c1b8f8ee5cbb802c99a50 a86f1a6b72e27af87ec9929b538a0a0ef3a608ea 434e86abe54eaf3ae2d0316e7fbcb9cb34a51e2d 1dc16a547610583b27312587346f31d6cf9bd35a ee769c2fa4515bfc8b7c3ada207bf45ba3f6df5c

PATH="${PATH}:${TOOLCHAINDIR}:${TOOLCHAIN32}:/pipeline/build/root/toolchain/gclang/clang-r349610/bin"
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"
#export CC=/pipeline/build/root/toolchain/dtc/bin/clang
#export CC=/pipeline/build/root/toolchain/gclang/clang-r349610/bin
#export CXX=/pipeline/build/root/toolchain/dtc/bin/clang++
export CC=clang
export CXX=clang++
export CLANG_TRIPLE=aarch64-linux-gnu-
#export CROSS_COMPILE=$TOOLCHAINDIR/bin/aarch64-linux-android-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-
#export LD_LIBRARY_PATH=$TOOLCHAINDIR/lib/
export USE_CCACHE=1
export CCACHE_DIR=$CCACHEDIR/.ccache

ls $TOOLCHAIN32

make clean && make mrproper
make -C $KERNEL_DIR capriszar_defconfig
make -C $KERNEL_DIR  -j$( nproc --all )

{
cp $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/capricorn
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
fi
}

cd $ANYKERNEL_DIR/capricorn
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
mv $FINAL_ZIP /pipeline/output/$FINAL_ZIP
