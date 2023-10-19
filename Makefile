ARCHS = arm64 arm64e
TARGET = iphone:clang:15.5:8.0

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DisintegrateLock

$(TWEAK_NAME)_FILES = Tweak.x DisintegrationDirection.swift CALayer+Disintegrate.swift UIView+Disintegrate.swift
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
#$(TWEAK_NAME)_FRAMEWORKS += Foundation UIKit AVFoundation QuartzCore
$(TWEAK_NAME)_EXTRA_FRAMEWORKS += Cephei

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += disintegratelockprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
