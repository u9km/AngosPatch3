# إعدادات البناء الاحترافية [BLACK AND AMAR VIP]
ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = Launcher

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = BlackAndAmarVIP

# نستخدم .mm لدعم Objective-C++ وتجنب الكشف الفوري
BlackAndAmarVIP_FILES = Tweak.mm
BlackAndAmarVIP_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk
