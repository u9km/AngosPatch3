# اسم الأداة (Tweak Name)
TWEAK_NAME = AngosPatcher

# ملفات المصدر (Source Files)
AngosPatcher_FILES = Tweak.x

# المكتبات الأساسية (Frameworks)
# أضفنا UIKit لإظهار الزر الأخضر في اللوبي
AngosPatcher_FRAMEWORKS = UIKit Foundation Security QuartzCore

# إعدادات المعالج (Compiler Flags)
# أضفنا -fobjc-arc لدعم إدارة الذاكرة تلقائياً وتجنب الكراش
AngosPatcher_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function

# استهداف معمارية 64-bit الحديثة فقط
ARCHS = arm64

# استهداف إصدارات iOS الحديثة
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

