
# -----------------------------------------------------------------
# OTA Package for GNU/Linux

ifeq ($(GNULINUX_OTA_OS),)
  GNULINUX_OTA_OS := archlinux
endif
ifeq ($(GNULINUX_OTA_ARCH),)
  GNULINUX_OTA_ARCH := armv7
endif

include ./hybris/packaging/$(GNULINUX_OTA_OS)/ota.mk

GNULINUX_SYSTEM_IMAGE_OUT := $(PRODUCT_OUT)/$(GNULINUX_SYSTEM_IMAGE_FILE)
GNULINUX_CHROOT_IMAGE_OUT := $(PRODUCT_OUT)/gnulinux-chroot.tgz

GNULINUX_CHROOT_EXTRA_FILES := $(shell (ls -1 "./hybris/packaging/$(GNULINUX_OTA_OS)/$(GNULINUX_CHROOT_INCLUDE_FILES)" | tr '\n' ' ')) ./hybris/packaging/$(GNULINUX_OTA_OS)/postinstall.sh

$(GNULINUX_CHROOT_IMAGE_OUT): $(GNULINUX_CHROOT_EXTRA_FILES)
	@echo "Package chroot postinstall: $@"
	$(hide) tar -czf $@ $(GNULINUX_CHROOT_EXTRA_FILES)

$(GNULINUX_SYSTEM_IMAGE_OUT):
	@echo "Downloading GNU/Linux Image: $@"
	curl -L $(GNULINUX_SYSTEM_IMAGE_URL) -o $@

ifndef BOARD_CUSTOM_GNULINUX_OTA_MK
INTERNAL_OTA_PACKAGE_TARGET := $(PRODUCT_OUT)/$(GNULINUX_OTA_OS)-$(GNULINUX_OTA_ARCH)-$(TARGET_DEVICE).zip

$(INTERNAL_OTA_PACKAGE_TARGET): KEY_CERT_PAIR := $(DEFAULT_KEY_CERT_PAIR)

$(INTERNAL_OTA_PACKAGE_TARGET): $(DISTTOOLS) $(BUILT_TARGET_FILES_PACKAGE) $(GNULINUX_SYSTEM_IMAGE_OUT) $(GNULINUX_CHROOT_IMAGE_OUT)
	@echo "Package GNU/Linux OTA: $@"
	MKBOOTIMG=$(MKBOOTIMG) \
	    ./build/tools/releasetools/ota_from_target_files -v \
            -p $(HOST_OUT) \
            -k $(KEY_CERT_PAIR) \
            -n \
	    --gnulinux \
	    --gnulinux_os=$(GNULINUX_OTA_OS) \
	    --gnulinux_chroot="$(GNULINUX_CHROOT_IMAGE_OUT)" \
	    --gnulinux_image=$(GNULINUX_SYSTEM_IMAGE_OUT) \
	    $(BUILT_TARGET_FILES_PACKAGE) $@
else
include $(BOARD_CUSTOM_GNULINUX_OTA_MK)
endif #BOARD_CUSTOM_GNULINUX_OTA_MK



