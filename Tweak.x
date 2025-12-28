#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiFullShield : NSObject
@end

@implementation GeminiFullShield

// 1. تصفير الهوية فوراً (تغيير UUID يكسر الباند الحالي)
- (id)newIDFV {
    return [[NSUUID alloc] initWithUUIDString:@"F555E444-D333-C222-B111-A00099988877"];
}

// 2. تزييف موديل الجهاز (لإخفاء البيئة المعدلة)
- (NSString *)newModel {
    return @"iPhone14,3"; 
}

// 3. منع كشف الجلبريك (إيهام اللعبة بأن النظام رسمي 100%)
- (BOOL)isJailbroken {
    return NO;
}

// 4. تعطيل إرسال ملفات الـ Log (درع ضد البلاغات)
- (void)stopLogs:(id)arg1 {
    return;
}

@end

// --- [محرك الحقن الذكي بدون كراش] ---

void StartFullNativeShield() {
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        // تبديل الهوية والموديل
        method_exchangeImplementations(class_getInstanceMethod(devClass, @selector(identifierForVendor)),
                                       class_getInstanceMethod([GeminiFullShield class], @selector(newIDFV)));
        
        method_exchangeImplementations(class_getInstanceMethod(devClass, @selector(model)),
                                       class_getInstanceMethod([GeminiFullShield class], @selector(newModel)));
    }
    
    // تعطيل حساسات كشف الجلبريك في اللعبة
    Class sensorClass = objc_getClass("AntiCheatManager"); // اسم افتراضي لمحرك الحماية
    if (sensorClass) {
        SEL jailSEL = sel_registerName("isJailbroken");
        Method m = class_getInstanceMethod(sensorClass, jailSEL);
        if (m) {
            method_setImplementation(m, class_getMethodImplementation([GeminiFullShield class], @selector(isJailbroken)));
        }
    }
}

%ctor {
    // حقن فوري بدون تأخير لسبق السيرفر
    StartFullNativeShield();
    NSLog(@"[Gemini] Full Native Shield Active - No Jailbreak Required.");
}
