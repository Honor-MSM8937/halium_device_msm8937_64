#!/bin/bash
set -ex

KERNEL_OBJ=$(realpath $1)
RAMDISK=$(realpath $2)
KERNEL=$(realpath $4)
RAMDISK_IMG=$(realpath $3)

HERE=$(pwd)
source "${HERE}/deviceinfo"

case "$deviceinfo_arch" in
    aarch64*) ARCH="arm64" ;;
    arm*) ARCH="arm" ;;
    x86_64) ARCH="x86_64" ;;
    x86) ARCH="x86" ;;
esac

if [ -d "$HERE/ramdisk-overlay" ]; then
    cp "$RAMDISK" "${RAMDISK}-merged"
    RAMDISK="${RAMDISK}-merged"
    cd "$HERE/ramdisk-overlay"
    find . | cpio -o -H newc | gzip >> "$RAMDISK"
fi

RAMDISK_RECOVERY="$HERE/recovery/ramdisk-recovery.img"

if [ -d "$HERE/recovery/overlay" ] && [ -e "$HERE/recovery/ramdisk-recovery.img" ]; then
    mkdir -p "$HERE/ramdisk-recovery"
    cd "$HERE/ramdisk-recovery"

    gzip -dc "$HERE/recovery/ramdisk-recovery.img" | cpio -i
    cp -r "$HERE/recovery/overlay"/* "$HERE/ramdisk-recovery"

    find . | cpio -o -H newc | gzip > "$HERE/recovery/ramdisk-recovery-overlayed.img"
    RAMDISK_RECOVERY="$HERE/recovery/ramdisk-recovery-overlayed.img"
fi

mkbootimg --kernel "$KERNEL_OBJ/arch/$ARCH/boot/Image.gz-dtb" --base $deviceinfo_flash_offset_base --kernel_offset $deviceinfo_flash_offset_kernel --ramdisk_offset $deviceinfo_flash_offset_ramdisk --second_offset $deviceinfo_flash_offset_second --tags_offset $deviceinfo_flash_offset_tags --pagesize $deviceinfo_flash_pagesize --os_version $deviceinfo_os_version --os_patch_level $deviceinfo_os_patch_level --cmdline "$deviceinfo_kernel_cmdline" -o "$KERNEL"
mkbootimg --kernel "$HERE/$deviceinfo_ramdisk_dummy_kernel" --ramdisk "$RAMDISK" --base $deviceinfo_flash_offset_base --kernel_offset $deviceinfo_flash_offset_kernel --ramdisk_offset $deviceinfo_flash_offset_ramdisk --second_offset $deviceinfo_flash_offset_second --tags_offset $deviceinfo_flash_offset_tags --pagesize $deviceinfo_flash_pagesize --os_version $deviceinfo_os_version --os_patch_level $deviceinfo_os_patch_level --cmdline "$deviceinfo_kernel_cmdline" -o "$RAMDISK_IMG"

#mkbootimg --kernel "$KERNEL_OBJ/arch/$ARCH/boot/Image.gz-dtb" --ramdisk "$RAMDISK_RECOVERY" --base $deviceinfo_flash_offset_base --kernel_offset $deviceinfo_flash_offset_kernel --ramdisk_offset $deviceinfo_flash_offset_ramdisk --second_offset $deviceinfo_flash_offset_second --tags_offset $deviceinfo_flash_offset_tags --pagesize $deviceinfo_flash_pagesize --os_version $deviceinfo_os_version --os_patch_level $deviceinfo_os_patch_level --cmdline "$deviceinfo_kernel_cmdline" -o "$(dirname $OUT)/recovery.img"
