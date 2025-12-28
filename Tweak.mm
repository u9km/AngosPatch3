#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- قسم الحماية المتقدمة ---

// 1. دالة تزييف هوية الجهاز (IDFV Spoofer)
// تمنع الشركة من ربط حسابك بجهازك الأصلي لتجنب "باند الجهاز"
void ApplyIdentityShield() {
    Method m = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
    method_setImplementation(m, imp_implementationWithBlock(^(id self) {
        return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]];
    }));
}

// 2. دالة منع كشف ملفات النظام (Anti-Cheat Bypass)
// تقوم بخداع نظام حماية اللعبة لكي لا يرى ملفات السورس أو الجيلبريك
bool (*orig_file_exists)(NSFileManager*, SEL, NSString*);
bool hooked_file_exists(NSFileManager* self, SEL _cmd, NSString* path) {
    if ([path containsString:@"Library/MobileSubstrate"] || 
        [path containsString:@"Cydia"] || 
        [path containsString:@"usr/lib/libsub"]) {
        return NO; // إخبار اللعبة أن هذه الملفات غير موجودة
    }
    return orig_file_exists(self, _cmd, path);
}

// --- قسم التشغيل الآمن لملف AMAR VIP ---

__attribute__((constructor)) static void Global_Security_Init() {
    // تشغيل نظام تزييف الهوية فوراً
    ApplyIdentityShield();
    
    // حقن كود منع الكشف داخل نظام الملفات
    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)hooked_file_exists, (IMP*)&orig_file_exists);

    // التحميل الذكي (تأخير 15 ثانية لضمان استقرار اللعبة وتخطي الفحص الأولي)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // المسار الذي سيتم إنشاء الفريم ورك فيه (يجب أن يطابق اسم الفريم ورك في Makefile)
        NSString *securePath = @"/Library/Frameworks/MetalCoreEngine.framework/AMAR_VIP.dylib";
        
        void *v8_handle = dlopen([securePath UTF8String], RTLD_NOW);
        
        if (v8_handle) {
            NSLog(@"[SECURITY] AMAR VIP Loaded Successfully inside Shield.");
        } else {
            // إذا حاول أحد العبث بالفريم ورك أو لم يجد الملف، تغلق اللعبة حمايةً للحساب
            // exit(0);
        }
    });
}
