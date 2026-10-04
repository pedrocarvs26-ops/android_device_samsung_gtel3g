# Wi-Fi-only variant (SM-T560).  Same board as the SM-T561, no modem.
GTEL_RIL := false

# Release name
PRODUCT_RELEASE_NAME := gtelwifi

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

# Inherit device configuration
$(call inherit-product, device/samsung/gtel3g/gtel3g.mk)

## Device identifier. This must come after all inclusions
PRODUCT_DEVICE := gtel3g
PRODUCT_NAME := lineage_gtelwifi
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-T560
PRODUCT_MANUFACTURER := samsung
PRODUCT_CHARACTERISTICS := tablet

# Stock build fingerprint
BUILD_FINGERPRINT := "samsung/gtelwifixx/gtelwifi:4.4.4/KTU84P/T560XXU0APL1:user/release-keys"
PRIVATE_BUILD_DESC := "gtelwifixx-user 4.4.4 KTU84P T560XXU0APL1 release-keys"

PRODUCT_PROPERTY_OVERRIDES += \
	ro.build.fingerprint=$(BUILD_FINGERPRINT)
