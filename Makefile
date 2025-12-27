# اسم الأداة - يجب أن يطابق الاسم في ملف الـ Control
TWEAK_NAME = AngosPatcher

# ملفات المصدر (Source Files)
AngosPatcher_FILES = Tweak.x

# المكتبات البرمجية المطلوبة للهوك والواجهة
# substrate: أساسية لعمل MSHookFunction
AngosPatcher_LIBRARIES = substrate
# UIKit & Foundation: للواجهة والأزرار
# Security: لعمليات تشفير الهوية وحمايتها
AngosPatcher_FRAMEWORKS = UIKit Foundation Security QuartzCore

# إعدادات المعالج (Compiler Flags) لضمان عدم الكراش
# -fobjc-arc: إدارة الذاكرة تلقائياً
# -Wno-deprecated-declarations: لتجاهل تحذيرات الأكواد القديمة (مثل keyWindow)
# -Wno-unused-variable: لتجاهل المتغيرات غير المستخدمة
AngosPatcher_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

# استهداف المعمارية الحديثة (iPhone 5s وما فوق)
ARCHS = arm64

# استهداف إصدار iOS (مناسب للأجهزة بدون جلبريك)
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
