#!/bin/bash

KERNEL_DIR=$PWD
ANYKERNEL_DIR=$KERNEL_DIR/AnyKernel2
CCACHEDIR=../CCACHE/capricorn
TOOLCHAINDIR=/pipeline/build/root/toolchain/aarch64-linux-android-4.9
#TOOLCHAINDIR=/pipeline/build/root/toolchain/jonas/linaro_gcc/aarch64-linux-gnu-7.4.1-2019.02
TOOLCHAIN32=/pipeline/build/root/toolchain/arm-linux-androideabi-4.9
TOOLDTC=/pipeline/build/root/toolchain/dtc
TOOLGC=/pipeline/build/root/toolchain/gclang/clang-r349610/
DATE=$(date +"%d%m%Y")
KERNEL_NAME="Syberia"
DEVICE="-capricorn-"
VER="-0.5-"
TYPE="PIE-EAS"
FINAL_ZIP="$KERNEL_NAME""$DEVICE""$DATE""$TYPE""$VER".zip

rm $ANYKERNEL_DIR/capricorn/Image.gz-dtb
rm $KERNEL_DIR/arch/arm64/boot/Image.gz $KERNEL_DIR/arch/arm64/boot/Image.gz-dtb
PATH="/pipeline/build/root/toolchain/gclang/clang-r349610/bin:${TOOLCHAINDIR}/bin:${TOOLCHAIN32}/bin:${PATH}"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/lib"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/aarch64-linux-android/lib"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAINDIR}/aarch64-linux-android/lib64"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAIN32}/lib"
#export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:${TOOLCHAIN32}/arm-linux-androideabi/lib"
export LD_LIBRARY_PATH="/pipeline/build/root/toolchain/gclang/clang-r349610/lib64:$LD_LIBRARY_PATH"
export ARCH=arm64
export KBUILD_BUILD_USER="mesziman"
export KBUILD_BUILD_HOST="github"
#export CC=/pipeline/build/root/toolchain/dtc/bin/clang
#export CC=/pipeline/build/root/toolchain/gclang/clang-r349610/bin
#export CXX=/pipeline/build/root/toolchain/dtc/bin/clang++
export CC=/pipeline/build/root/toolchain/gclang/clang-r349610/bin/clang
export CXX=/pipeline/build/root/toolchain/gclang/clang-r349610/bin/clang++
#export cc-name=clang
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=aarch64-linux-android-
export CROSS_COMPILE_ARM32=arm-linux-androideabi-
#export CROSS_COMPILE=aarch64-linux-android-
#export CROSS_COMPILE_ARM32=arm-linux-androideabi-
#export LD_LIBRARY_PATH=$TOOLCHAINDIR/lib/
export USE_CCACHE=1
export CCACHE_DIR=$CCACHEDIR/.ccache
echo "===================WHICH========================="
echo "which CLANG_TRIPLE $(which ${CLANG_TRIPLE}-ld)"
echo "which CC $(which ${CC})"
echo "which 32tc $(which ${CROSS_COMPILE_ARM32}ld))"
echo "which ${CROSS_COMPILE_ARM32}gcc"
env "cc-name=clang" sh -c 'echo "cc-name: ${cc-name}"'
echo "realpath of 32tc $(realpath $(dir $(which ${CROSS_COMPILE_ARM32}ld))/..)"

echo "===================WHICH========================="
env "cc-name=clang"  make clean && make mrproper
env "cc-name=clang" make O=out -C $KERNEL_DIR capriszar_defconfig

env "cc-name=clang" make O=out -C $KERNEL_DIR  -j$( nproc --all )

{
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb $ANYKERNEL_DIR/capricorn
} || {
if [ $? != 0 ]; then
  echo "FAILED BUILD"
fi
}
echo "======================VERIFY CLANG==============================="
cat $KERNEL_DIR/out/include/generated/compile.h
echo "======================VERIFY CLANG==============================="
cd $ANYKERNEL_DIR/capricorn
zip -r9 $FINAL_ZIP * -x *.zip $FINAL_ZIP
cp $FINAL_ZIP ${WERCKER_REPORT_ARTIFACTS_DIR}/
mv $FINAL_ZIP /pipeline/output/$FINAL_ZIP
