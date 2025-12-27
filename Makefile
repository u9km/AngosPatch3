TWEAK_NAME = AngosPatcher
AngosPatcher_FILES = Tweak.x
AngosPatcher_LIBRARIES = substrate
AngosPatcher_FRAMEWORKS = UIKit Foundation Security

# السطر السحري لحل المشكلة:
AngosPatcher_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
