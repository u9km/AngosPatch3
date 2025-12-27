TWEAK_NAME = AngosPatcher
AngosPatcher_FILES = Tweak.x
AngosPatcher_FRAMEWORKS = UIKit Foundation Security CoreGraphics QuartzCore AdSupport SystemConfiguration

AngosPatcher_CFLAGS = -fobjc-arc -O3 -Wno-deprecated-declarations
AngosPatcher_LDFLAGS = -Wl,-segalign,4000

ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
