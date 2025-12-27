#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>

@interface GeminiUltra : NSObject
@end

@implementation GeminiUltra

// 1. تزييف معرف الجهاز (أساسي لمنع الحظر الغيابي)
- (id)hookedIDFV {
    return [[NSUUID alloc] initWithUUIDString:@"D721E1F8-C48D-4B1E-92FC-0C347A2E7F6B"];
}

// 2. تزييف الـ Bundle ID (يجعل اللعبة تظن أنها النسخة الرسمية)
- (NSString *)hookedBundleID {
    return @"com.tencent.ig"; 
}

@end

// --- [محرك الحماية من كشف التعديلات] ---

void StartAimbotProtection() {
    // استخدام "Method Swizzling" لأنه لا يلمس ملفات اللعبة الأصلية (بدون كراش)
    
    // هوك الهوية (IDFV)
    Method origIdfv = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
    Method swizIdfv = class_getInstanceMethod([GeminiUltra class], @selector(hookedIDFV));
    method_exchangeImplementations(origIdfv, swizIdfv);
    
    // هوك الـ Bundle ID (منع اكتشاف النسخة المعدلة)
    Method origBundle = class_getInstanceMethod([NSBundle class], @selector(bundleIdentifier));
    Method swizBundle = class_getInstanceMethod([GeminiUltra class], @selector(hookedBundleID));
    method_exchangeImplementations(origBundle, swizBundle);

    NSLog(@"[Gemini] Aimbot Stealth Protection Active.");
}

%ctor {
    // تأخير طويل جداً (110 ثانية)
    // السر: يتم تفعيل الحماية بعد أن تكون قد بدأت المباراة أو دخلت اللوبي واستقرت الحماية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(110 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        StartAimbotProtection();
    });
}
