#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiEmpire : NSObject
@end

@implementation GeminiEmpire
// توليد ID عشوائي ثابت لكل جلسة لعب لمنع تضارب البيانات
- (id)newIDFV { 
    static NSUUID *sessionUUID;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionUUID = [NSUUID UUID];
    });
    return sessionUUID;
}
@end

// دالة عرض رسالة الترحيب الاحترافية
void ShowVipWelcome() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        // طريقة حديثة وآمنة لجلب النافذة لمنع الكراش في iOS 13+
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = ((UIWindowScene *)scene).windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window) {
            UIView *vipView = [[UIView alloc] initWithFrame:CGRectMake(window.frame.size.width/2 - 140, 60, 280, 45)];
            vipView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
            vipView.layer.cornerRadius = 12;
            vipView.layer.borderWidth = 1.5;
            vipView.layer.borderColor = [UIColor colorWithRed:1.0 green:0.84 blue:0.0 alpha:1.0].CGColor; // ذهبي
            vipView.alpha = 0;

            UILabel *vipLabel = [[UILabel alloc] initWithFrame:vipView.bounds];
            vipLabel.text = @"🔥 BLACK AND AMAR VIP 🔥";
            vipLabel.textColor = [UIColor whiteColor];
            vipLabel.textAlignment = NSTextAlignmentCenter;
            vipLabel.font = [UIFont boldSystemFontOfSize:15];
            
            [vipView addSubview:vipLabel];
            [window addSubview:vipView];

            [UIView animateWithDuration:0.8 animations:^{ vipView.alpha = 1; } completion:^(BOOL f) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.8 animations:^{ vipView.alpha = 0; } completion:^(BOOL f2){ [vipView removeFromSuperview]; }];
                });
            }];
        }
    });
}

void SafeActivate() {
    // هوك IDFV بطريقة أكثر استقراراً
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        Method m1 = class_getInstanceMethod(devClass, @selector(identifierForVendor));
        Method m2 = class_getInstanceMethod([GeminiEmpire class], @selector(newIDFV));
        if (m1 && m2) method_exchangeImplementations(m1, m2);
    }

    // هوك البندل آيدي
    Method mBundle = class_getInstanceMethod([NSBundle class], @selector(bundleIdentifier));
    if (mBundle) {
        method_setImplementation(mBundle, imp_implementationWithBlock(^NSString* (id self) {
            return @"com.apple.Music"; 
        }));
    }
    
    ShowVipWelcome();
}

%ctor {
    // زيادة التأخير لـ 8 ثوانٍ لضمان استقرار اللوبي تماماً قبل الحقن
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SafeActivate();
    });
}
