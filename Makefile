ARCHS = arm64 arm64e
TARGET = iphone:clang:latest:14.0
INSTALL_TARGET_PROCESSES = ShadowTrackerExtra

include $(THEOS)/makefiles/common.mk

# اسم الفريم ورك (يظهر للمحققين كملف نظام)
FRAMEWORK_NAME = MetalPerformanceCore
MetalPerformanceCore_FILES = Tweak.mm
MetalPerformanceCore_INSTALL_PATH = /Library/Frameworks
MetalPerformanceCore_CFLAGS = -fobjc-arc -O3 -fvisibility=hidden

include $(THEOS_MAKE_PATH)/framework.mk
