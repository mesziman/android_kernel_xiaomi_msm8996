#!/bin/bash


dpkg --add-architecture amd64 && apt-get -qq update && apt-get -qq install -y libomp-dev binutils-arm-linux-gnueabi g++-multilib gcc-multilib binutils-aarch64-linux-gnu git ccache automake bc lzop bison gperf build-essential zip curl zlib1g-dev  g++-multilib python-networkx libxml2-utils bzip2 libbz2-dev libbz2-1.0 libghc-bzlib-dev squashfs-tools pngcrush schedtool dpkg-dev liblz4-tool make optipng &&
export LOFASZ=$PWD && 
git clone --depth=2 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 /pipeline/build/root/toolchain/aarch64-linux-android-4.9 &&
cd /pipeline/build/root/toolchain/aarch64-linux-android-4.9 && git reset --hard 22f053ccdfd0d73aafcceff3419a5fe3c01e878b &&
git clone --depth=2 https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9 /pipeline/build/root/toolchain/arm-linux-androideabi-4.9 &&
cd /pipeline/build/root/toolchain/arm-linux-androideabi-4.9 && git reset --hard 42e5864a7d23921858ca8541d52028ff88acb2b6 &&
git clone --depth=2 https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86 /pipeline/build/root/toolchain/gclang &&
git clone --depth=1 -b 6.0.9 https://github.com/nvertigo/llvm-Snapdragon_LLVM_for_Android /pipeline/build/root/toolchain/SnapDragonLLVM_6.0/prebuilt/linux-x86_64/
git clone --depth=2 -b 9.0 https://github.com/syberia-project/platform_prebuilts_build-tools /pipeline/build/root/toolchain/asd
git clone --depth=1 https://bitbucket.org/xanaxdroid/dragontc-9.0.git /pipeline/build/root/toolchain/dtc
git clone --depth=1 https://bitbucket.org/jonascardoso/toolchain_aarch64_travis.git /pipeline/build/root/toolchain/jonas
git clone --depth=1 https://github.com/Z3Prover/z3.git ~/z3 && cd ~/z3 && python scripts/mk_make.py && cd build && make && make install
ls /usr/lib/libz*
ls /usr/lib64/libz*
cd $LOFASZ
bash builder-mi5s.sh
