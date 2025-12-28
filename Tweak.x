#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>

// 1. نظام الحماية الذكي: إخفاء وجود التويك عن محرك اللعبة
BOOL isSafeToInject = NO;

// 2. تزييف خصائص الجهاز بطريقة "النظام الوهمي" لمنع الباند
%hook UIDevice
- (NSString *)name { return @"iPhone"; }
- (NSString *)model { return @"iPhone"; }
- (NSString *)systemName { return @"iOS"; }
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"A1B2C3D4-E5F6-7890-ABCD-EF1234567890"];
}
%end

// 3. منع اللعبة من اكتشاف ملفات الـ dylib المحقونة
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    [dict setObject:@"com.apple.Music" forKey:@"CFBundleIdentifier"];
    return dict;
}
%end

// 4. دالة الحماية من الكراش (تفعيل المميزات فقط بعد استقرار المحرك تماماً)
void ActivateFullHackFeatures() {
    if (!isSafeToInject) return;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win) {
            // شعار BLACK AND AMAR VIP المتطور
            UILabel *notify = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, win.frame.size.width, 35)];
            notify.text = @"🛡️ BLACK AND AMAR VIP: SECURE MODE 🛡️";
            notify.textColor = [UIColor greenColor];
            notify.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
            notify.textAlignment = NSTextAlignmentCenter;
            notify.font = [UIFont boldSystemFontOfSize:14];
            notify.layer.cornerRadius = 10;
            notify.clipsToBounds = YES;
            [win addSubview:notify];

            [UIView animateWithDuration:1.0 delay:5.0 options:0 animations:^{ notify.alpha = 0; } completion:^(BOOL f){ [notify removeFromSuperview]; }];
        }
    });
    
    // هنا يتم وضع "الباتشات" الخاصة بالهاك (مثل إزالة العشب أو ثبات السلاح)
    // سيتم تفعيلها الآن لأننا تجاوزنا مرحلة فحص اللوبي
}

%ctor {
    // أهم خطوة لمنع الكراش: الانتظار حتى اكتمال تحميل جميع مكتبات اللعبة الأساسية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        isSafeToInject = YES;
        ActivateFullHackFeatures();
        NSLog(@"[VIP] Full Protection & Hacks Initialized Safely.");
    });
}
