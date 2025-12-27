# اسم الأداة
TWEAK_NAME = AngosPatcher

# ملفات العمل
AngosPatcher_FILES = Tweak.x

# إطار العمل (Frameworks)
# نكتفي بالمكتبات الأساسية للنظام لضمان العمل بدون خيار الجلبريك
AngosPatcher_FRAMEWORKS = UIKit Foundation Security

# إعدادات البناء المتقدمة
# -fobjc-arc: لضمان إدارة الذاكرة ومنع كراشات تسريب الذاكرة
# -O3: لتحسين سرعة الكود وجعله أخف على معالج اللعبة
AngosPatcher_CFLAGS = -fobjc-arc -O3 -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

# سطر المحاذاة الذهبي: ضروري جداً للأجهزة بدون جلبريك لمنع الكراش
AngosPatcher_LDFLAGS = -Wl,-segalign,4000

# المعمارية المستهدفة
ARCHS = arm64
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
