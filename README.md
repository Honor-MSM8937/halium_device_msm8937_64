# Ubuntu Touch device tree for the Honor 7A Pro (msm8937_64)

This is based on Halium 9.0, and uses the mechanism described in [this
page](https://github.com/ubports/porting-notes/wiki/GitLab-CI-builds-for-devices-based-on-halium_arm64-(Halium-9)).

## How to build

To manually build this project, follow these steps:

```bash
./build.sh -b bd  # bd is the name of the build directory
./build/prepare-fake-ota.sh out/device_msm8937_64.tar.xz ota
./build/system-image-from-ota.sh ota/ubuntu_command out
```
