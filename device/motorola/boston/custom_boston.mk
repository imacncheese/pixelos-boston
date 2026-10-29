#
# Copyright (C) 2026 The PixelOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# PixelOS product for the Motorola Moto G Stylus 5G 2024 (boston)

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
TARGET_SUPPORTS_OMX_SERVICE := false
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from boston device
$(call inherit-product, device/motorola/boston/device.mk)

# Inherit PixelOS common configuration (also inherits vendor/lineage common)
$(call inherit-product, vendor/custom/config/common_full_phone.mk)

# PixelOS build identity
CUSTOM_BUILD := boston
IS_OFFICIAL := false

PRODUCT_NAME := custom_boston
PRODUCT_DEVICE := boston
PRODUCT_MANUFACTURER := motorola
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto g stylus 5G - 2024

PRODUCT_GMS_CLIENTID_BASE := android-motorola

# NOTE: no PRODUCT_BUILD_PROP_OVERRIDES here on purpose. Forcing a stock
# "-user/release-keys" fingerprint while the build is signed with test keys
# makes ro.build.tags (test-keys) disagree with the OTA metadata post-build
# fingerprint, and recovery rejects the package with a build-tag mismatch.
