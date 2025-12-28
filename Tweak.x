#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// --- إعدادات الحماية الفائقة ---
// تزييف الهوية لمنع الباند الطرف الثالث والغيابي
%hook UIDevice
- (NSUUID *)identifierForVendor {
    return [[NSUUID alloc] initWithUUIDString:@"00000000-0000-0000-0000-000000000000"];
}
- (NSString *)name { return @"iPhone"; }
- (NSString *)systemVersion { return @"15.0"; }
%end

// --- تزييف بيئة التطبيق (فل هاك صامت) ---
// هذا الجزء يوهم اللعبة أنها في بيئة تطوير رسمية، مما يفتح بعض الميزات ويقلل الحماية
%hook NSBundle
- (NSDictionary *)infoDictionary {
    NSMutableDictionary *dict = [%orig mutableCopy];
    [dict setObject:@"com.apple.Music" forKey:@"CFBundleIdentifier"];
    [dict setObject:@"1.0.0" forKey:@"CFBundleShortVersionString"];
    return dict;
}
%end

// --- منع الكراش الفوري (إخفاء الملفات) ---
// منع اللعبة من رؤية ملف الـ dylib الخاص بنا في الذاكرة
%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([path containsString:@"Library/MobileSubstrate"] || [path containsString:@".dylib"]) {
        return NO;
    }
    return %orig;
}
%end

// --- واجهة BLACK AND AMAR VIP الاحترافية ---
void LoadVipInterface() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            UIView *topBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, 30)];
            topBar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            
            UILabel *status = [[UILabel alloc] initWithFrame:topBar.bounds];
            status.text = @"🛡️ BLACK AND AMAR VIP: FULL PROTECTION ACTIVE 🛡️";
            status.textColor = [UIColor cyanColor];
            status.font = [UIFont boldSystemFontOfSize:12];
            status.textAlignment = NSTextAlignmentCenter;
            
            [topBar addSubview:status];
            [window addSubview:topBar];
            
            // اختفاء تدريجي أنيق
            [UIView animateWithDuration:2.0 delay:10.0 options:0 animations:^{ topBar.alpha = 0; } completion:^(BOOL f){ [topBar removeFromSuperview]; }];
        }
    });
}

// --- مشغل الحماية (Constructor) ---
%ctor {
    // أهم سر لمنع الكراش بدون جلبريك: التأخير الذكي
    // نحن ننتظر حتى ينتهي نظام الحماية من الفحص الساكن عند التشغيل
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        LoadVipInterface();
        NSLog(@"[VIP] Security Layers Injected Successfully.");
    });
}
