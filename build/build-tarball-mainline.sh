set -ex

device=$1
output=$(realpath $2)
dir=$(realpath $3)

echo "Working on device: $device"
if [ ! -f "$dir/partitions/kernel.img" ]; then
    echo "kernel.img does not exist!"
exit 1; fi

if [! -f "$dir/partitions/ramdisk.img" ]; then
    echo "ramdisk.img does not exist!"
exit 1; fi

if [ ! -f "$dir/partitions/dtbo.img" ]; then
    echo "WARNING: dtbo.img does not exist"
fi

if [ ! -f "$dir/partitions/recovery.img" ]; then
    echo "WARNING: recovery.img does not exist"
fi

TAR_EXTRA_OPTIONS=""
if [ "$TARGET_DISTRO" == "focal" ]; then
    TAR_EXTRA_OPTIONS="--transform=s,^system/lib,system/usr/lib,"
fi

tar -cJf "$output/device_"$device".tar.xz" \
    --owner=:0 --group=:0 --mode='go-w' \
    $TAR_EXTRA_OPTIONS \
    -C $dir partitions/ system/
echo "$(date +%Y%m%d)-$RANDOM" > "$output/device_"$device".tar.build"
