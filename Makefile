TWEAK_NAME = AngosPatcher
AngosPatcher_FILES = Tweak.x
AngosPatcher_LIBRARIES = substrate
AngosPatcher_FRAMEWORKS = UIKit Foundation Security

# أعلام تمنع الكراش وتحسن الأداء
AngosPatcher_CFLAGS = -fobjc-arc -O3 -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function
# سطر ضروري جداً للمحاذاة في الأجهزة بدون جلبريك
AngosPatcher_LDFLAGS = -Wl,-segalign,4000

ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
