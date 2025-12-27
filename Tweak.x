#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <substrate.h>

// تعريف الدوال الأصلية لضمان عدم حدوث تضارب في الذاكرة
static id (*orig_idfv)(id self, SEL _cmd);
static int (*orig_access)(const char *path, int mode);

// --- [دوال الحماية المعدلة] ---

// هوك تزييف الهوية لمنع الباند الغيابي (Silent IDFV Spoofer)
id hooked_idfv(id self, SEL _cmd) {
    // إرجاع معرف وهمي ثابت يحمي جهازك من الحظر الرقمي
    return @"B921E1F8-C48D-4B1E-92FC-0C347A2E7F6B";
}

// هوك إخفاء الملفات (Anti-Detection)
int hooked_access(const char *path, int mode) {
    if (path != NULL) {
        // إخفاء أي أثر لمكتبات الحقن أو ملفات التعديل
        if (strstr(path, "Library/MobileSubstrate") || strstr(path, "dylib") || strstr(path, "Tweak")) {
            return -1; 
        }
    }
    return orig_access(path, mode);
}

// --- [محرك التشغيل التلقائي بدون كراش] ---

void StartGeminiUltimateProtection() {
    // 1. هوك Objective-C (الأكثر استقراراً على الإطلاق للأجهزة بدون جلبريك)
    Class deviceClass = objc_getClass("UIDevice");
    if (deviceClass) {
        SEL idfvSelector = sel_registerName("identifierForVendor");
        MSHookMessageEx(deviceClass, idfvSelector, (IMP)hooked_idfv, (IMP *)&orig_idfv);
    }

    // 2. هوك الدوال النظامية باستخدام dlsym للوصول الآمن
    void *access_ptr = dlsym(RTLD_DEFAULT, "access");
    if (access_ptr) {
        MSHookFunction(access_ptr, (void *)hooked_access, (void **)&orig_access);
    }

    NSLog(@"[Gemini] Ultimate Protection Engaged - No Crash Mode.");
}

%ctor {
    // تأخير التفعيل لـ 80 ثانية لضمان أن اللعبة تخطت كافة فحوصات التشغيل (Startup Checksum)
    // هذا هو السر في منع الكراش للأجهزة بدون جلبريك
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(80 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StartGeminiUltimateProtection();
    });
}
