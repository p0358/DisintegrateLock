#TARGET := iphone:clang:13.5:11.2
TARGET := iphone:clang:13.5:8.0
INSTALL_TARGET_PROCESSES = SpringBoard

#ARCHS = arm64 arm64e
ARCHS = arm64
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
