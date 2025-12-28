# تحديد المعماريات المدعومة (arm64 للأجهزة القديمة و arm64e للحديثة)
ARCHS = arm64 arm64e

# استهداف أحدث إصدار متاح لضمان التوافق مع أنظمة iOS الجديدة
TARGET := iphone:clang:latest:14.0

# استدعاء ملفات الـ Theos الأساسية
include $(THEOS)/makefiles/common.mk

# اسم المشروع (يجب أن يتطابق مع اسم ملف الـ .plist)
TWEAK_NAME = GeminiEmpire

# الملفات البرمجية المطلوب تجميعها
GeminiEmpire_FILES = Tweak.x

# المكتبات (Frameworks) التي يحتاجها الكود للعمل (مهمة جداً لمنع الكراش)
GeminiEmpire_FRAMEWORKS = UIKit Foundation Security CoreGraphics

# إعدادات المترجم (Compiler Flags) لضمان استقرار الكود
GeminiEmpire_CFLAGS = -fobjc-arc -Wno-deprecated-declarations

include $(THEOS_MAKE_PATH)/tweak.mk

# أمر لتنظيف اللعبة وإعادة تشغيلها عند التثبيت (للمطورين)
after-install::
	install.exec "killall -9 SpringBoard"
