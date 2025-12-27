ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AngosPatcher
AngosPatcher_FILES = Tweak.x
AngosPatcher_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
