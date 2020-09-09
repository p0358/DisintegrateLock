#THEOS_DEVICE_IP = 10.0.0.225
#GO_EASY_ON_ME = 1


#PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)
#PACKAGE_VERSION = $(THEOS_PACKAGE_BASE_VERSION)-$(VERSION.INC_BUILD_NUMBER)$(VERSION.EXTRAVERSION)

#TARGET := iphone:clang:latest:7.0
#TARGET := iphone:clang:latest:11.2
#TARGET := iphone:13.5:12.0
#TARGET := iphone:11.2:11.2
#TARGET := iphone:clang:13.5:13.0
#TARGET := iphone:clang:13.5:11.2
TARGET := iphone:clang:13.5:8.0
#TARGET := iphone:clang:11.2:11.2
INSTALL_TARGET_PROCESSES = SpringBoard

#ARCHS = arm64 arm64e
ARCHS = arm64
#SDKVERSION = 13.3
#SYSROOT = $(THEOS)/sdks/iPhoneOS13.3.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DisintegrateLock

$(TWEAK_NAME)_FILES = Tweak.x DisintegrationDirection.swift CALayer+Disintegrate.swift UIView+Disintegrate.swift
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
#$(TWEAK_NAME)_FRAMEWORKS += Foundation UIKit AVFoundation QuartzCore
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += disintegratelockprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
