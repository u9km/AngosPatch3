#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

// تشفير المسارات لمنع الحماية من معرفة ما نقوم بحذفه
#define CLOUD_PATH @"Documents/ShadowTrackerExtra/Saved/CloudStorage"
#define STAT_PATH @"Documents/ShadowTrackerExtra/Saved/StatCache"

@interface NewSecurityBypass : NSObject
@end

@implementation NewSecurityBypass
- (id)initDynamic { return [[NSUUID UUID] UUIDString]; }
- (void)stop { return; }
@end

// تنظيف "صامت" للمسارات التي استحدثتها ببجي في التحديث الأخير
void SilentPurge() {
    NSString *h = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *targets = @[
        @"Library/Caches/com.tencent.ig",
        @"Library/WebKit", 
        @"Documents/ShadowTrackerExtra/Saved/Logs",
        CLOUD_PATH,
        STAT_PATH
    ];
    for (NSString *t in targets) {
        [fm removeItemAtPath:[h stringByAppendingPathComponent:t] error:nil];
    }
}

// تخطي فحص الذاكرة الجديد (Anti-Memory Scan)
void ProtectMemory() {
    // استهداف محرك Turing الجديد الذي أُضيف في التحديث
    Class turing = objc_getClass("TuringMessenger");
    if (turing) {
        Method m = class_getInstanceMethod(turing, sel_registerName("sendMessage:"));
        if (m) method_setImplementation(m, class_getMethodImplementation([NewSecurityBypass class], @selector(stop)));
    }
}

__attribute__((constructor)) static void final_shield() {
    // مسح فوري للملفات قبل بدء اتصال السيرفر
    SilentPurge();

    // تأخير الحقن لـ 65 ثانية لضمان استقرار اللعبة وتخطي فحص اللوبي
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(65 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ProtectMemory();
        
        // تزييف هوية الجهاز بأسلوب الـ Block لمنع الكشف
        Method idfv = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
        method_setImplementation(idfv, imp_implementationWithBlock(^(id self) {
            return [[NSUUID alloc] initWithUUIDString:[[NSUUID UUID] UUIDString]];
        }));

        // دورة تنظيف فائقة السرعة كل 10 ثوانٍ لمواجهة سرعة التحديث
        [NSTimer scheduledTimerWithTimeInterval:10.0 repeats:YES block:^(NSTimer *timer) {
            SilentPurge();
        }];
    });
}
