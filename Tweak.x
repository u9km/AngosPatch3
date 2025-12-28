#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiStableGuard : NSObject
@end

@implementation GeminiStableGuard
// توليد معرف جديد عند كل تشغيل لتخطي الباند الغيابي
- (id)newIDFV { 
    return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]]; 
}
@end

void ActivateStableShield() {
    // 1. هوك الهوية والموديل
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        method_exchangeImplementations(class_getInstanceMethod(devClass, @selector(identifierForVendor)),
                                       class_getInstanceMethod([GeminiStableGuard class], @selector(newIDFV)));
    }

    // 2. تزييف البندل آيدي لزيادة الأمان
    Class bundleClass = [NSBundle class];
    if (bundleClass) {
        Method m = class_getInstanceMethod(bundleClass, @selector(bundleIdentifier));
        if (m) {
            method_setImplementation(m, imp_implementationWithBlock(^NSString* (id self) {
                return @"com.apple.Music"; 
            }));
        }
    }
}

%ctor {
    // تم إضافة تأخير 5 ثوانٍ بناءً على طلبك لضمان عدم الكراش
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ActivateStableShield();
        
        // إظهار تنبيه بسيط يؤكد تفعيل الحماية بعد مرور الـ 5 ثوانٍ
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, window.frame.size.width, 30)];
        label.text = @"STABLE PROTECTION: ON";
        label.textColor = [UIColor greenColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [window addSubview:label];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [label removeFromSuperview];
        });
        
        NSLog(@"[Gemini] Shield Activated after 5s delay.");
    });
}
