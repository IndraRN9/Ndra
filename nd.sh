#!/bin/sh

DEFCONFIG="ndra_defconfig"
CLANGDIR="/workspace/build/clang"

#
rm -rf out
rm -rf compile.log

#
mkdir -p out
mkdir out/Ndra


#
export KBUILD_BUILD_USER=Ndrα
export KBUILD_BUILD_HOST=ND-Irαwαn
export PATH="$CLANGDIR/bin:$PATH"

#
make O=out ARCH=arm64 $DEFCONFIG

#
MAKE="./makeparallel"

#
START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

nd () {
make -j$(nproc --all) O=out LLVM=1 \
ARCH=arm64 \
CC=clang \
LD=ld.lld \
AR=llvm-ar \
AS=llvm-as \
NM=llvm-nm \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump \
STRIP=llvm-strip \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=arm-linux-gnueabi-
}

#Run
cp Ndra/SE/* arch/arm64/boot/dts/qcom/
cp Ndra/GPU/sdm845-v2.dtsi arch/arm64/boot/dts/qcom/
cp Ndra/GPU/gpucc-sdm845.c drivers/clk/qcom/
cp Ndra/10.3.7/* firmware/
nd 2>&1 | tee -a compile.log
if [ $? -ne 0 ]
then
    echo "Build failed"
else
    echo "Build succesful"
    cp out/arch/arm64/boot/Image.gz-dtb out/Ndra/Image.gz-dtb
fi

END=$(date +"%s")
DIFF=$(($END - $START))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
