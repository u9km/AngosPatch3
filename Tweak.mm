#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GlobalProtector : NSObject
@end

@implementation GlobalProtector
// تزييف الهوية
- (id)fakeUUID { return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]]; }
// تزييف إصدار النظام إلى 12.1 (إصدار قديم ومستقر)
- (NSString *)fakeOSVersion { return @"12.1"; }
- (NSString *)fakeModel { return @"iPhone 8"; }
@end

// تنظيف ملفات الباند الغيابي
void PowerClean() {
    NSString *home = NSHomeDirectory();
    NSArray *paths = @[
        @"Library/Caches", @"Library/Logs", @"tmp",
        @"Documents/ShadowTrackerExtra/Saved/Logs",
        @"Documents/ShadowTrackerExtra/Saved/Pandora",
        @"Documents/ShadowTrackerExtra/Saved/SrcCheck",
        @"Documents/ShadowTrackerExtra/Saved/StatCache"
    ];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *p in paths) {
        [fm removeItemAtPath:[home stringByAppendingPathComponent:p] error:nil];
    }
}

void ActivateSpoofing() {
    Class dev = objc_getClass("UIDevice");
    if (dev) {
        // 1. تزييف رقم الإصدار (System Version)
        method_setImplementation(class_getInstanceMethod(dev, @selector(systemVersion)),
                                 class_getMethodImplementation([GlobalProtector class], @selector(fakeOSVersion)));
        
        // 2. تزييف نوع الجهاز لمنع التدقيق المتقاطع
        method_setImplementation(class_getInstanceMethod(dev, @selector(model)),
                                 class_getMethodImplementation([GlobalProtector class], @selector(fakeModel)));

        // 3. تزييف الهوية (IDFV)
        method_setImplementation(class_getInstanceMethod(dev, @selector(identifierForVendor)),
                                 class_getMethodImplementation([GlobalProtector class], @selector(fakeUUID)));
    }
}

__attribute__((constructor)) static void load() {
    // تنظيف أولي صامت
    PowerClean();

    // تأخير 60 ثانية لتجاوز فحوصات الأمان الثقيلة عند البداية
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ActivateSpoofing();
        
        // تنظيف دوري شرس كل 30 ثانية لقتل الباند الغيابي
        [NSTimer scheduledTimerWithTimeInterval:30.0 repeats:YES block:^(NSTimer *timer) {
            PowerClean();
        }];
        
        NSLog(@"[VIP] SYSTEM SPOOFING & ANTI-BAN ACTIVE.");
    });
}
