#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

// --- 1. نظام تشفير النصوص (لإخفاء الروابط والمسارات عن الرادار) ---
#define XOR_KEY 0xFA
NSString* OBF(const char* data, int len) {
    char* decrypted = (char*)malloc(len + 1);
    for (int i = 0; i < len; i++) decrypted[i] = data[i] ^ XOR_KEY;
    decrypted[len] = '\0';
    NSString* result = [NSString stringWithUTF8String:decrypted];
    free(decrypted);
    return result;
}

// --- 2. نظام تزييف هوية الجهاز (IDFV Spoofer) ---
// هذا الكود يمنع اللعبة من عمل "باند جهاز" لأنه يغير الـ ID في كل تشغيل
void ApplyDeviceGuard() {
    Method m = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
    method_setImplementation(m, imp_implementationWithBlock(^(id self) {
        return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]];
    }));
}

// --- 3. نظام حماية الذاكرة ومنع الكشف (Anti-Detection) ---
// تعطيل الدوال التي تبحث عن الجيلبريك أو الملفات المشبوهة
bool (*orig_access)(const char *, int);
bool hook_access(const char *path, int mode) {
    // إذا حاولت اللعبة الوصول لمجلدات السيديا أو الأدوات، نخبرها أنها غير موجودة
    if (strstr(path, "/Library/MobileSubstrate") || strstr(path, "/usr/bin/cydia")) {
        return -1; 
    }
    return orig_access(path, mode);
}

// --- 4. نقطة الانطلاق (التشغيل الذكي) ---
__attribute__((constructor)) static void SafeEntry() {
    // تفعيل الحمايات فوراً عند فتح اللعبة
    ApplyDeviceGuard();
    MSHookFunction((void *)access, (void *)hook_access, (void **)&orig_access);

    // الانتظار حتى استقرار اللعبة (15 ثانية) ثم استدعاء ملف AMAR VIP
    // هذا التأخير هو ما يمنع كشف "الطرف الثالث" في بداية اللوبي
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // المسار الذي سيتواجد فيه الملف داخل الـ Framework المشفر
        NSString *libPath = @"/Library/Frameworks/MetalCoreEngine.framework/AMAR_VIP.dylib";
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:libPath]) {
            void *handle = dlopen([libPath UTF8String], RTLD_NOW);
            if (handle) {
                NSLog(@"[SHIELD] Protection Active & Menu Loaded.");
            }
        }
    });
}

