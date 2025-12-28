#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- 1. نظام تشفير المسارات (لإخفاء الملفات عن رادار اللعبة) ---
#define SECRET_KEY 0xDE
NSString* Decrypt_Str(int* data, int len) {
    char* out = (char*)malloc(len + 1);
    for(int i=0; i<len; i++) out[i] = data[i] ^ SECRET_KEY;
    out[len] = '\0';
    NSString* res = [NSString stringWithUTF8String:out];
    free(out);
    return res;
}

// --- 2. نظام تزييف هوية الجهاز (Device ID Spoofer) ---
// هذا الجزء يمنع الشركة من التعرف على جهازك الأصلي أو حظر الـ UDID الخاص بك
void Start_Spoofing() {
    Method m = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
    method_setImplementation(m, imp_implementationWithBlock(^(id self) {
        // توليد معرف عشوائي جديد تماماً عند كل تشغيل للعبة
        return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]];
    }));
}

// --- 3. نظام منع كشف الجيلبريك والأدوات (Anti-Cheat Bypass) ---
// يقوم بتزييف نتائج البحث عن ملفات مثل Cydia أو ملفات الأدوات المعدلة
bool (*orig_fileExistsAtPath)(NSFileManager*, SEL, NSString*);
bool hooked_fileExistsAtPath(NSFileManager* self, SEL _cmd, NSString* path) {
    if ([path containsString:@"Cydia"] || [path containsString:@"MobileSubstrate"] || [path containsString:@"usr/lib/libsub"]) {
        return NO; // إيهام اللعبة أن هذه الملفات غير موجودة
    }
    return orig_fileExistsAtPath(self, _cmd, path);
}

// --- 4. المحرك الأساسي (Constructor) ---
__attribute__((constructor)) static void Protection_Shield_Init() {
    // تشغيل تزييف الهوية فوراً عند فتح التطبيق
    Start_Spoofing();
    
    // إخفاء وجود الجيلبريك عن محرك اللعبة
    Method m2 = class_getInstanceMethod([NSFileManager class], @selector(fileExistsAtPath:));
    orig_fileExistsAtPath = (bool (*)(NSFileManager*, SEL, NSString*))method_getImplementation(m2);
    method_setImplementation(m2, imp_implementationWithBlock(^(id self, NSString* path) {
        return hooked_fileExistsAtPath(self, @selector(fileExistsAtPath:), path);
    }));

    // تأخير تشغيل ملف التفعيلات AMAR VIP لضمان تخطي فحص البداية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // تحميل ملف التفعيلات من داخل الفريم ورك بأمان
        NSString *securePath = @"/Library/Frameworks/MetalCoreEngine.framework/AMAR_VIP.dylib";
        void *handle = dlopen([securePath UTF8String], RTLD_NOW);
        
        if (handle) {
            NSLog(@"[SECURITY] AMAR VIP LOADED UNDER PROTECTION SHIELD.");
        }
    });
}
