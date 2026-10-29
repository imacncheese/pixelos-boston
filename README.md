# PixelOS 16.2 bring-up for the Motorola Moto G Stylus 5G (2024) — `boston`

This repository contains the minimal set of changes needed to build **PixelOS 16.2 (Android 16 QPR2)**
for the Motorola Moto G Stylus 5G 2024 (XT2419-1, codename `boston`, SM6450) on top of the
[PixelOS-AOSP](https://github.com/PixelOS-AOSP) `sixteen-qpr2` manifest and
[evoxdl](https://github.com/evoxdl)'s `lineage-23.2` device trees.

The resulting ROM was built from source, flashed to a real device and verified booting
(PixelOS 16.2, Android 16 / SDK 36, kernel `5.10.257-gki-g9708121d5855`).

## Device / kernel source

* [MotorolaMobilityLLC/kernel-msm#822](https://github.com/MotorolaMobilityLLC/kernel-msm/issues/822)
  is the kernel source request for `boston`; it is closed with the `published` label (2026-05-15),
  so Motorola has released the GPL kernel source.
* Device/kernel/vendor trees used: `device/motorola/boston`, `device/motorola/sm6450-common`,
  `vendor/motorola/{boston,sm6450-common}`, `kernel/motorola/sm6450{,-modules,-devicetrees}`,
  `hardware/motorola` — all at branch `lineage-23.2` (see `local_manifests/boston.xml`).

## Build

```bash
repo init -u https://github.com/PixelOS-AOSP/android_manifest -b sixteen-qpr2 --depth=1 --git-lfs
cp local_manifests/boston.xml .repo/local_manifests/boston.xml
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags

# apply the changes from this repository
cp -r device/* .          # custom_boston.mk + AndroidProducts.mk
git -C vendor/lineage apply patches/0001-*.patch
git -C device/motorola/sm6450-common apply patches/0002-*.patch
git -C device/motorola/boston apply patches/0003-*.patch

source build/envsetup.sh
lunch custom_boston-bp4a-user
mka pixelos -j12
# -> out/target/product/boston/PixelOS_boston-16.2-<date>.zip
```

A cold build takes ~2 h 35 min on 20 vCPUs / 31 GB RAM; incremental builds with ccache take ~8 min.

## What is in here

| Path | Purpose |
|---|---|
| `device/motorola/boston/custom_boston.mk` | PixelOS product (`custom_<codename>` naming required by `vendor/custom/build/envsetup.sh`); no `PRODUCT_BUILD_PROP_OVERRIDES`, so `ro.build.tags` and the OTA metadata stay consistent (`test-keys`) |
| `device/motorola/boston/AndroidProducts.mk` | registers `lineage_boston` + `custom_boston` and the lunch choices |
| `patches/0001-*.patch` | `build-manifest_xml.mk`: run `repo manifest` with a writable `HOME`, the Soong sandbox makes `$HOME` read-only |
| `patches/0002-*.patch` | GNSS VINTF: empty the AIDL v1 fragment (Android 16 requires AIDL v2) and keep **both** HIDL `@1.1` and `@2.1` so `hwservicemanager` accepts the 2.1 service |
| `patches/0003-*.patch` | `AndroidProducts.mk` change |
| `scripts/` | the exact helper scripts used (deps, sync, build, collect artifacts) |
| `docs/BUILD-REPORT.md` | full report: environment, verification output, flashing procedure, caveats |

## Flashing (test-key signed, unlocked bootloader)

```bash
adb reboot bootloader
fastboot flash recovery recovery.img
fastboot reboot
adb reboot sideload
adb sideload PixelOS_boston-16.2-<date>.zip
```

The full OTA writes the inactive slot and reboots into it. Recovery is a user build with
`ro.adb.secure=1`, so `adb` in the recovery menu is unauthorized until confirmed; sideload does not
need authorization.

## Notes / limitations

* Not an official PixelOS device: no official OTA server, builds are test-key signed.
* GNSS runs on the HIDL 2.1 service; the vendor's AIDL GNSS implementation is `gnss-V1-ndk` and is
  rejected by the Android 16 compatibility matrix.
* The ROM boots on top of stock `userdata` (FBE keys are valid because the vendor/TEE side is
  unchanged); a factory reset is recommended for a clean state.
