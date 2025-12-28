#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiTenSecondShield : NSObject
@end

@implementation GeminiTenSecondShield

// تغيير الـ UUID لكسر بصمة الباند 2035
- (id)newIDFV {
    return [[NSUUID alloc] initWithUUIDString:@"D333E444-F555-A666-B777-C888D999E000"];
}

- (NSString *)newModel {
    return @"iPhone14,3"; 
}

@end

// دالة التنظيف وتفعيل الحماية
void ActivateTenSecondShield() {
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        method_exchangeImplementations(class_getInstanceMethod(devClass, @selector(identifierForVendor)),
                                       class_getInstanceMethod([GeminiTenSecondShield class], @selector(newIDFV)));
        
        method_exchangeImplementations(class_getInstanceMethod(devClass, @selector(model)),
                                       class_getInstanceMethod([GeminiTenSecondShield class], @selector(newModel)));
    }
}

%ctor {
    // الانتظار لمدة 10 ثوانٍ لضمان عدم حدوث شاشة سوداء
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ActivateTenSecondShield();
        
        // إظهار تنبيه بسيط لتأكيد التفعيل
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIView *toast = [[UIView alloc] initWithFrame:CGRectMake(window.frame.size.width/2 - 75, 40, 150, 35)];
        toast.backgroundColor = [UIColor darkGrayColor];
        toast.layer.cornerRadius = 10;
        toast.alpha = 0.8;
        
        UILabel *label = [[UILabel alloc] initWithFrame:toast.bounds];
        label.text = @"Full Hack: ACTIVE";
        label.textColor = [UIColor greenColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:12];
        
        [toast addSubview:label];
        [window addSubview:toast];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toast removeFromSuperview];
        });
    });
}
