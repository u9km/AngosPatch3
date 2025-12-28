#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// دالة لجلب الهوية بشكل صامت تماماً دون عمل هوك تقليدي
static NSString* GetFakeID() {
    return [[NSUUID UUID] UUIDString];
}

void FinalStableInjection() {
    // 1. هوك البندل آيدي باستخدام Block (أكثر استقراراً وأماناً)
    Method m = class_getInstanceMethod([NSBundle class], @selector(bundleIdentifier));
    if (m) {
        method_setImplementation(m, imp_implementationWithBlock(^NSString* (id self) {
            return @"com.apple.Music"; 
        }));
    }

    // 2. تغيير الهوية (IDFV) بطريقة الـ "Direct Replacement" لمنع كراش اللوبي
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        Method idfvMethod = class_getInstanceMethod(devClass, @selector(identifierForVendor));
        if (idfvMethod) {
            method_setImplementation(idfvMethod, imp_implementationWithBlock(^id(id self) {
                return [[NSUUID alloc] initWithUUIDString:GetFakeID()];
            }));
        }
    }

    // 3. إظهار شعار BLACK AND AMAR VIP (بشكل آمن)
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, window.frame.size.width, 30)];
            label.text = @"✨ BLACK AND AMAR VIP: ACTIVE ✨";
            label.textColor = [UIColor cyanColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont boldSystemFontOfSize:14];
            label.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
            [window addSubview:label];
            
            [UIView animateWithDuration:1.0 delay:4.0 options:0 animations:^{ label.alpha = 0; } completion:^(BOOL f){ [label removeFromSuperview]; }];
        }
    });
}

%ctor {
    // تأخير طويل (12 ثانية) لضمان تجاوز فحص الحماية الأولي للوبي
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(12 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        FinalStableInjection();
    });
}
