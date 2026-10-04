# Copyright (C) 2017 The Lineage Project
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

LOCAL_PATH := device/samsung/gtel3g

# SM-T560 (Wi-Fi only) vs SM-T561 (3G).  Both models are the exact same SoC and
# board, so they share this tree; the T560 simply has no modem.
# lineage_gtelwifi.mk sets this to false.
GTEL_RIL ?= true

# Telephony base
ifeq ($(GTEL_RIL),true)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)
else
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)
PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/handheld_core_hardware.xml:$(TARGET_COPY_OUT_VENDOR)/etc/permissions/handheld_core_hardware.xml
endif

# Overlays
DEVICE_PACKAGE_OVERLAYS += $(LOCAL_PATH)/overlay

# Inherit from vendor tree
$(call inherit-product-if-exists, vendor/samsung/gtel3g/gtel3g-vendor.mk)

# Inherit from SC8830 platform configuration
$(call inherit-product, device/samsung/scx35-common/common.mk)

# Telephony / RIL
#
# Starting rild/modemd on a modem-less T560 just loops forever on
#   RILClient: Connect_RILD: Connecting failed. Connection refused(111)
# so the whole Spreadtrum RIL stack is left out of the Wi-Fi-only variant.
#
# The shim libraries stay in both variants on purpose: the Samsung audio HAL
# links libsecril-client, so dropping it would break audio on the T560.
PRODUCT_PACKAGES += \
	librilutils \
	libril_shim \
	libphoneserver_shim \
	libatchannel \
	libsecril-client \
	libsecril-shim

ifeq ($(GTEL_RIL),true)

PRODUCT_PACKAGES += \
	SamsungServiceMode \
	modemd \
	modem_control

PRODUCT_PROPERTY_OVERRIDES += \
	ro.radio.modemtype=w \
	rild.libpath=/system/vendor/lib/libsecril-shim.so \
	ro.com.android.mobiledata=false

PRODUCT_COPY_FILES += \
	frameworks/native/data/etc/android.hardware.telephony.gsm.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.hardware.telephony.gsm.xml \
	$(LOCAL_PATH)/ril/init/at_distributor.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/at_distributor.rc \
	$(LOCAL_PATH)/ril/init/data.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/data.rc \
	$(LOCAL_PATH)/ril/init/dns.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/dns.rc \
	$(LOCAL_PATH)/ril/init/engpc.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/engpc.rc \
	$(LOCAL_PATH)/ril/init/gtel3g-ril.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/gtel3g-ril.rc \
	$(LOCAL_PATH)/ril/init/kill_phone.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/kill_phone.rc \
	$(LOCAL_PATH)/ril/init/modem_control.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/modem_control.rc \
	$(LOCAL_PATH)/ril/init/modemd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/modemd.rc \
	$(LOCAL_PATH)/ril/init/nvitemd.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/nvitemd.rc \
	$(LOCAL_PATH)/ril/init/phoneserver.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/phoneserver.rc \
	$(LOCAL_PATH)/ril/init/refnotify.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/refnotify.rc \
	$(LOCAL_PATH)/ril/init/rild.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/rild.legacy.rc \
	$(LOCAL_PATH)/ril/init/smd_symlink.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/smd_symlink.rc

else

# No modem
PRODUCT_PROPERTY_OVERRIDES += \
	ro.radio.noril=1 \
	ro.carrier=wifi-only \
	ro.multisim.simslotcount=0 \
	persist.radio.multisim.config=none \
	ro.com.android.mobiledata=false \
	ro.com.android.dataroaming=false \
	keyguard.no_require_sim=true

endif

# Boot animation
TARGET_SCREEN_HEIGHT := 1280
TARGET_SCREEN_WIDTH := 800

# Keylayouts
PRODUCT_COPY_FILES += \
	$(LOCAL_PATH)/keylayout/sec_touchscreen.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/sec_touchscreen.kl \
	$(LOCAL_PATH)/keylayout/samsung-keypad.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/samsung-keypad.kl \
	$(LOCAL_PATH)/keylayout/sci-keypad.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/sci-keypad.kl

# Media
PRODUCT_PACKAGES += \
	media_profiles_V1_0.xml

PRODUCT_PROPERTY_OVERRIDES += \
	media.stagefright.legacyencoder=true \
	media.stagefright.less-secure=true

# Camera
PRODUCT_PACKAGES += \
	Snap \
	camera.sc8830 \
	libmemoryheapion_sprd_legacy

# Sensors
PRODUCT_PACKAGES += \
	sensors.sc8830

# 18.1 port: generic bcmdhd overlays shadow the board ones; dropped.

# Set those variables here to overwrite the inherited values.
PRODUCT_NAME := full_gtel3g
PRODUCT_DEVICE := gtel3g
PRODUCT_BRAND := samsung
PRODUCT_MANUFACTURER := samsung
PRODUCT_MODEL := SM-T561

# Excluded hardware features
ifeq ($(GTEL_RIL),true)
PRODUCT_COPY_FILES += $(LOCAL_PATH)/configs/permissions/gtel3g_excluded_hardware.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/gtel3g_excluded_hardware.xml
else
PRODUCT_COPY_FILES += $(LOCAL_PATH)/configs/permissions/gtelwifi_excluded_hardware.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/gtelwifi_excluded_hardware.xml
endif

# Root filesystem
PRODUCT_PACKAGES += \
    fstab.sc8830

# 18.1 port: first stage init reads the fstab from the boot ramdisk before
# SYSTEM is mounted. The root copy above serves the second stage.
PRODUCT_COPY_FILES += \
    device/samsung/gtel3g/rootdir/fstab.sc8830:$(TARGET_COPY_OUT_RAMDISK)/fstab.sc8830

# SPRD offline charger
PRODUCT_PACKAGES += \
    # 18.1 port, TEMP: sprd_charger static link needs R rework; charger mode only.
    #sprd_charger
