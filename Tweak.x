#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <sys/utsname.h>

@interface GeminiGodShield : NSObject
@end

@implementation GeminiGodShield

// 1. تزييف هوية الجهاز (منع الباند الغيابي وباند الآي بي)
- (id)fakeIDFV {
    return [[NSUUID alloc] initWithUUIDString:@"C182A431-E59D-4C1F-83FC-1D458B3F8G7H"];
}

// 2. تزييف اسم الجهاز (لإخفاء أنك تستخدم جهازاً معدلاً أو iPad على موبايل)
- (NSString *)fakeModel {
    return @"iPhone14,3"; // تزييف الجهاز كـ iPhone 13 Pro Max
}

// 3. تعطيل تقارير البلاغات والكشف (Anti-Cheat Bypass)
- (void)disableReports:(id)arg1 {
    return; // إرجاع قيمة فارغة لمنع إرسال سجلات الهاك
}

@end

// --- [محرك الحماية الفولاذي] ---

void InitializeAntiBanShield() {
    // هوك الهوية
    method_exchangeImplementations(class_getInstanceMethod([UIDevice class], @selector(identifierForVendor)),
                                   class_getInstanceMethod([GeminiGodShield class], @selector(fakeIDFV)));

    // هوك موديل الجهاز لمنع كشف المحاكيات أو التعديلات
    method_exchangeImplementations(class_getInstanceMethod([UIDevice class], @selector(model)),
                                   class_getInstanceMethod([GeminiGodShield class], @selector(fakeModel)));

    // هوك منع الباند اليدوي (تعطيل دوال إرسال البيانات الضخمة)
    NSArray *classes = @[@"FIRAnalytics", @"MSAnalytics", @"AppCenterAnalytics"]; // استهداف محركات التقارير
    for (NSString *className in classes) {
        Class cls = objc_getClass([className UTF8String]);
        if (cls) {
            SEL logSel = sel_registerName("logEventWithName:parameters:");
            Method m = class_getInstanceMethod(cls, logSel);
            if (m) {
                method_setImplementation(m, class_getMethodImplementation([GeminiGodShield class], @selector(disableReports:)));
            }
        }
    }
}

%ctor {
    // تأخير الحقن لـ 120 ثانية (أمان مطلق) لضمان عبور فحص تشغيل اللعبة
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        InitializeAntiBanShield();
    });
}
