# Name of the Tweak
TWEAK_NAME = AngosPatcher

# Source files
AngosPatcher_FILES = Tweak.x

# Required Frameworks for UI and Security
AngosPatcher_FRAMEWORKS = UIKit Foundation Security QuartzCore

# Compiler Flags to fix errors shown in screenshots
# -fobjc-arc: for automatic memory management
# -Wno-deprecated-declarations: to ignore 'keyWindow' warnings
# -Wno-unused-variable: to ignore 'gameBase' warnings
AngosPatcher_CFLAGS = -fobjc-arc -Wno-deprecated-declarations -Wno-unused-variable -Wno-unused-function

# Target architecture (modern 64-bit devices)
ARCHS = arm64

# Deployment target
TARGET = iphone:clang:latest:14.0

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

