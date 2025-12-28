#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- قسم التشفير الذكي (XOR) ---
// مفتاح التشفير الخاص بنا
#define SECRET_KEY 0xAD 

// دالة لفك تشفير النصوص في الذاكرة فقط (لإخفاء المسارات عن الرادار)
NSString* decrypt_secure_path(int* data, int len) {
    char* out = (char*)malloc(len + 1);
    for(int i=0; i<len; i++) out[i] = data[i] ^ SECRET_KEY;
    out[len] = '\0';
    NSString* res = [NSString stringWithUTF8String:out];
    free(out);
    return res;
}

// --- نظام تزييف الهوية (IDFV Spoofer) ---
// يمنع اللعبة من التعرف على جهازك الأصلي أو حظره (باند جهاز)
void start_identity_spoofing() {
    Method m = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
    method_setImplementation(m, imp_implementationWithBlock(^(id self) {
        // توليد معرف عشوائي جديد في كل مرة يتم فيها تشغيل اللعبة
        return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]];
    }));
}

// --- نظام الحماية المتكاملة والتشغيل الآمن ---
__attribute__((constructor)) static void GlobalShieldInit() {
    // 1. تفعيل تزييف الهوية فوراً
    start_identity_spoofing();

    // 2. إخفاء وجود الملفات المعدلة (Anti-Jailbreak Detection)
    // نستخدم XOR هنا لتشفير كلمة "Library/MobileSubstrate"
