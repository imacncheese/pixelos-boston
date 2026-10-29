# PixelOS 16.2 for the Motorola Moto G Stylus 5G (2024) — `boston`

Built from source on this machine and **installed on the connected phone**. Verified booting.

| | |
|---|---|
| ROM | PixelOS 16.2 (Android 16 QPR2, `BP4A.251205.006`) |
| OTA | `PixelOS_boston-16.2-20261029-0334.zip` (2 305 715 357 B, sha256 `1b8a032f…37b983`) |
| Kernel | `5.10.257-gki-g9708121d5855`, compiled from source |
| Slot | `b` → after install the device runs slot `a` |
| SELinux | Enforcing |
| GMS | included (85 Google packages) |

## Device

| Property | Value |
|---|---|
| Serial | `ZY22JQ7GXL` |
| Codename / product | `boston` / `boston_g` |
| Model | XT2419-1, moto g stylus 5G - 2024 |
| SoC | SM6450 (Snapdragon 6 Gen 1), platform `parrot` |
| Stock build it came from | `V1UBS35H.97-49-4-2`, Android 15 (SDK 35) |
| Bootloader | unlocked (`ro.boot.verifiedbootstate=orange`, `flash.locked=0`) |
| Partitions | A/B + dynamic `super` (7 818 182 656 B) |

## Kernel source status

[MotorolaMobilityLLC/kernel-msm#822](https://github.com/MotorolaMobilityLLC/kernel-msm/issues/822) is the
kernel-source request for `boston`. It is **closed with the `published` label** (closed 2026-05-15),
i.e. Motorola has released the GPL kernel source for this device.

The build uses `evoxdl`'s `lineage-23.2` trees — the same ones the existing unofficial PixelOS 16.2
for `boston` was built from — on top of the PixelOS `sixteen-qpr2` manifest:

```
device/motorola/boston              device/motorola/sm6450-common
vendor/motorola/boston              vendor/motorola/sm6450-common
kernel/motorola/sm6450              kernel/motorola/sm6450-modules
kernel/motorola/sm6450-devicetrees  hardware/motorola
```

## Build environment

* Windows 11 host, WSL2 Ubuntu 26.04.1 LTS (kernel 6.18.54.1), 20 logical CPUs, 31 GB RAM + 16 GB swap
* Source/output on the WSL ext4 volume (`/root/pixelos`), ~250 GB used
* PixelOS 16.2 = Android 16 QPR2, AOSP tag `android-16.0.0_r4`, lunch release `bp4a`
* Toolchain: `openjdk-21-jdk-headless`, system `git`/`repo`, AOSP prebuilt clang and JDK

```bash
repo init -u https://github.com/PixelOS-AOSP/android_manifest -b sixteen-qpr2 --depth=1 --git-lfs
cp boston-local-manifest.xml .repo/local_manifests/boston.xml
repo sync -c -j8 --force-sync --no-clone-bundle --no-tags
source build/envsetup.sh
lunch custom_boston-bp4a-user
mka pixelos -j12
```

Cold build: 2 h 35 min to 91 % + 8 min incremental after the fixes below.

## Source changes made for this device

1. **PixelOS product for a LineageOS device tree** — the tree only ships `lineage_boston`, while PixelOS
   builds products named `custom_<codename>` (`vendor/custom/build/envsetup.sh`):
   * `device/motorola/boston/custom_boston.mk` (new)
   * `device/motorola/boston/AndroidProducts.mk` (adds the product + lunch choices)
   * Deliberately **no** `PRODUCT_BUILD_PROP_OVERRIDES`: forcing a stock `:user/release-keys`
     fingerprint while signing with test keys made `ro.build.tags=test-keys` disagree with the OTA
     metadata, and recovery rejected the package ("build tag … does not match").

2. **`vendor/lineage/build/tasks/build-manifest_xml.mk`** — the rule runs `repo manifest` inside the
   Soong namespace sandbox where `$HOME` is read-only, so `repo` failed writing
   `~/.repo_.gitconfig.json`. The rule now runs with `HOME=$(dir $@)`.

3. **GNSS VINTF** (`device/motorola/sm6450-common/gps/android/…`):
   * the AIDL fragment (`android.hardware.gnss-aidl-service-qti.xml`) is emptied: the Qualcomm AIDL
     implementation is `android.hardware.gnss-V1-ndk`, and Android 16 (FCM 7) rejects deprecated
     GNSS AIDL v1 ("requires at least 2");
   * the HIDL fragment (`android.hardware.gnss@2.1-service-qti.xml`) keeps **both** `@1.1` and `@2.1`
     fqnames — `hwservicemanager` refuses to register the 2.1 service unless its 1.1 superclass is
     declared. With the AIDL entry gone, `checkvintf` reports COMPATIBLE and the framework binds to
     HIDL GNSS 2.1.

## Verification on the phone

```
sys.boot_completed            = 1
ro.custom.version             = PixelOS_boston-16.2-20261029-0334
ro.build.version.release/sdk  = 16 / 36
ro.build.fingerprint          = motorola/custom_boston/boston:16/BP4A.251205.006/eng.root:user/test-keys
ro.boot.slot_suffix           = _a
uname -r                      = 5.10.257-gki-g9708121d5855
getenforce                    = Enforcing
init.svc.gnss_service         = running
pm list packages              = 271 (85 Google, 9 LineageOS)
crash buffer                  = no FATAL entries
battery / wifi                = 98 % charging / wlan0 up
```

## Artifacts (in `out/`)

| File | Size | sha256 |
|---|---|---|
| `PixelOS_boston-16.2-20261029-0334.zip` | 2 305 715 357 B | `1b8a032fe4d59167a4f94976b99aeca5a5ef2238116de206366cd4b77037b983` |
| `recovery.img` | 134 217 728 B | `72e66c37a3780df6bbbc182ae53db786efd264b3d843aa20a7d160f7e760f0d0` |
| `boot.img` | 100 663 296 B | `eac2cf729e088238911188780cb958ce2e29faedce701f750ee3aa21708d7f03` |
| `vendor_boot.img` | 100 663 296 B | `d5fe0b9726d4c0288ebfd2e8f22915dfdcd8b237990d3c338971e4e683b8f78f` |
| `dtbo.img` | 25 165 824 B | `1146e8cca9375d11671d6fdb47be679ed45e1bd57f2dc595ace44329e536de30` |

(The `…0210…` and `…0233…` zips in `out/` are earlier iterations that recovery rejects — use the
`…0334…` build.)

## Flashing procedure used

```bash
# 1. boot the stock system, then
adb reboot bootloader
fastboot flash recovery recovery.img      # writes recovery_a on slot a
fastboot reboot                           # stock Android comes back up
adb reboot sideload                       # enters PixelOS recovery in sideload mode
adb sideload PixelOS_boston-16.2-20261029-0334.zip
# recovery applies the payload to the inactive slot and reboots into it
```

Notes:
* Recovery is a **user** build with `ro.adb.secure=1`: `adb` in the recovery menu is *unauthorized*
  until you accept the prompt. In `sideload` mode no authorization is needed.
* The full OTA is ~47 % → 100 % in ~6 min on this machine, then the payload is applied; the first boot
  after the install takes a few minutes (dexopt of 271 packages).
* The ROM booted on top of the existing `/data` from Android 15 (FBE keys still valid because the
  vendor/TEE side is unchanged). If you want a clean state, do a factory reset from Settings.

## Recovery / fallback

Stock firmware for `boston` was downloaded to `/root/firmware/boston_cc_15.zip` inside WSL
(`XT2419-1_BOSTON_CC_15_V1UBS35H.97-24-4_…CFC.xml.zip`, 6 331 594 748 B). It is a *lower* build than
the `97-49-4-2` the phone shipped with, so Motorola anti-rollback may refuse it; use it only as a last
resort for individual partitions (e.g. `boot.img`) or with the `blankflash` package from the same
mirror. With an unlocked bootloader the phone can always be recovered through `fastboot`.

## Rebuild / reflash

Scripts used live in `F:\dsh\pixelos`:

| Script | Purpose |
|---|---|
| `01-deps.sh` | install AOSP build dependencies in WSL |
| `02-init.sh` | `repo init` the PixelOS `sixteen-qpr2` manifest |
| `04-sync.sh` | sync + `boston-local-manifest.xml` |
| `05-prep.sh` | swap/ccache/JDK checks |
| `06-build.sh` | `lunch custom_boston-bp4a-user && mka pixelos` |
| `08-build.sh` | detached build runner (logs to `/root/pixelos-build.log`) |
| `10-collect.sh` | copy OTA + images to `out/` and print sha256 |
| `patches/` | the two GNSS VINTF fragments and the build-manifest fix |
| `device-files/` | `custom_boston.mk` + `AndroidProducts.mk` |
