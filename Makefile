# إعدادات المعمارية والهدف
TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = GeminiUltimate

# ربط ملفات الكود والمكتبات المطلوبة
GeminiUltimate_FILES = Tweak.x
GeminiUltimate_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
GeminiUltimate_FRAMEWORKS = UIKit Foundation Security

include $(THEOS_MAKE_PATH)/tweak.mk

# تنظيف الملفات المؤقتة بعد البناء لضمان نظافة الملف
after-install::
	install.exec "killall -9 SpringBoard"
