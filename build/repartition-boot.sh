#!/bin/bash
set -ex

echo "! Ubuntu only script for gh-actions."

echo "> Getting Images Info..."
echo "-> Getting all deps and AIK from SebaUbuntu/AIK-Linux-mirror..."
sudo apt update -y && sudo apt install git gzip lzop lzma tar bzip2 lz4 xz-utils cpio wget sudo file -y # Check up git
git clone https://github.com/SebaUbuntu/AIK-Linux-mirror aik-linux
cd aik-linux

echo "-> Getting test images..."
wget -O ramdisk.img $RAMDISK_IMAGE && wget -O kernel.img $KERNEL_IMAGE

echo "-> Unpacking boot image..."
cp $BOOT_IMAGE ./boot.img
bash unpackimg.sh ./boot.img
mkdir ../target && mv ramdisk split_img ../target 

echo "-> Repacking ramdisk.img..."
bash cleanup.sh && bash unpackimg.sh ./ramdisk.img # Unpacking ramdisk

cp ../target/split_img/boot.img-cmdline ./split_img/ramdisk.img-cmdline # Installing our options and ramdisk
rm -rf ./ramdisk && cp ../target/ramdisk ./ramdisk -r 
bash repackimg.sh && mv image-new.img ../target/ramdisk.img
sh cleanup.sh

echo "-> Repacking kernel.img..."
bash cleanup.sh && bash unpackimg.sh ./kernel.img

cp ../target/split_img/boot.img-cmdline ./split_img/kernel.img-cmdline # Installing our options and kernel
cp ../target/split_img/boot.img-kernel ./split_img/kernel.img-kernel 
bash repackimg.sh && mv image-new.img ../target/kernel.img
bash cleanup.sh && rm -rf ../target/split_img ../target/ramdisk
cd ..

echo "> Done; Uploading images..."
