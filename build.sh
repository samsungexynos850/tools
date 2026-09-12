#!/bin/bash

# Define the top level directory for the project
ROOT=$(pwd)

# Exit if any commands fail
set -e

# Compile Linux kernel
cd $ROOT/linux
make ARCH=arm64 LLVM=1 O=$ROOT/out/linux -j64 defconfig fragments/exynos850-a217f.config
make ARCH=arm64 LLVM=1 O=$ROOT/out/linux -j64 savedefconfig
make ARCH=arm64 LLVM=1 O=$ROOT/out/linux -j64

# Compile uniLoader (custom secondary bootloader)
cd $ROOT/uniLoader
cp $ROOT/out/linux/arch/arm64/boot/Image blob/Image
cp $ROOT/out/linux/arch/arm64/boot/dts/exynos/exynos850-a217f.dtb blob/dtb
cp $ROOT/tools/pmos-ramdisk blob/ramdisk
make ARCH=aarch64 LLVM=1 -j64 a21s_defconfig
make ARCH=aarch64 LLVM=1 -j64

# Build an android compatible boot image
cd $ROOT/tools/AIK-Linux
cp $ROOT/uniLoader/uniLoader split_img/boot.img-kernel
./repackimg.sh

# Copy resultant boot.img to images/
mkdir -p $ROOT/out/images
cp image-new.img $ROOT/out/images/boot.img

# Document where the final image is located
echo ""
echo -e "\033[32m* Flashable boot.img: out/images/boot.img\033[0m"
