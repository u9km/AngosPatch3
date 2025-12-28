#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <substrate.h> // استخدام المكتبة الأساسية مباشرة

// 1. تعريف الوظيفة الأصلية لتخزينها
static id (*orig_idfv)(UIDevice *, SEL);

// 2. الوظيفة البديلة (التزييف الصامت)
id swapped_idfv(UIDevice *self, SEL _cmd) {
    return [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}

// 3. دالة تنظيف المسارات (لحذف أثار الطرف الثالث)
void CleanGameLogs() {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

%ctor {
    // تنظيف ملفات السجل قبل أي إجراء
    CleanGameLogs();

    // تأخير الحقن لـ 40 ثانية (تجاوز الفحص الفوري عند الإقلاع)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(40 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // استبدال الوظيفة يدوياً في الذاكرة (أصعب في الاكتشاف)
        MSHookMessageEx(objc_getClass("UIDevice"), @selector(identifierForVendor), (IMP)swapped_idfv, (IMP *)&orig_idfv);
        
        // إظهار شعار التفعيل بعد الاستقرار التام
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            UILabel *vip = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, window.frame.size.width, 30)];
            vip.text = @"🛡️ BLACK AND AMAR VIP: LOADED 🛡️";
            vip.textColor = [UIColor whiteColor];
            vip.backgroundColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:0.8];
            vip.textAlignment = NSTextAlignmentCenter;
            [window addSubview:vip];
            [UIView animateWithDuration:1.0 delay:4.0 options:0 animations:^{ vip.alpha = 0; } completion:^(BOOL f){ [vip removeFromSuperview]; }];
        }
    });
}
