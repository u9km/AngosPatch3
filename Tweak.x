#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <substrate.h>

// --- [قسم التعريفات] ---
static id (*orig_idfv)(UIDevice *self, SEL _cmd);
static int (*orig_access)(const char *path, int mode);

// --- [دوال الحماية الصامتة] ---

// 1. تزييف الهوية تلقائياً
id hooked_idfv(UIDevice *self, SEL _cmd) {
    return @"A8B7C6D5-E4F3-2G1H-0I9J-K8L7M6N5O4P3";
}

// 2. إخفاء ملفات الأداة تلقائياً
int hooked_access(const char *path, int mode) {
    if (path != NULL) {
        if (strstr(path, "Library/MobileSubstrate") || strstr(path, "dylib") || strstr(path, "Tweak")) {
            return -1;
        }
    }
    return orig_access(path, mode);
}

// --- [محرك التشغيل التلقائي] ---

void StartSilentShield() {
    // تفعيل الهوك فوراً بدون تدخل المستخدم
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "access"), (void *)hooked_access, (void **)&orig_access);
    MSHookMessageEx([UIDevice class], @selector(identifierForVendor), (IMP)hooked_idfv, (IMP *)&orig_idfv);
    
    // طباعة رسالة في سجل النظام للتأكد من العمل (اختياري)
    NSLog(@"[Gemini] Silent Shield Engaged Successfully!");
}

%ctor {
    // الانتظار لمدة 40 ثانية ثم التفعيل تلقائياً في الخلفية
    // هذا التأخير يضمن أن اللعبة انتهت من فحص "بداية التشغيل"
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StartSilentShield();
    });
}
