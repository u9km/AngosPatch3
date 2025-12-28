#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiAutoShield : NSObject
@end

@implementation GeminiAutoShield

+ (NSString *)generateRandomUUID {
    return [[NSUUID UUID] UUIDString];
}

- (id)newIDFV {
    return [[NSUUID alloc] initWithUUIDString:[GeminiAutoShield generateRandomUUID]];
}

- (void)stopAnalytics:(id)arg1 { return; }

@end

// دالة تنظيف الملفات المصححة (حماية نهاية الجيم)
void CleanEndGameLogs() {
    // تم تصحيح اسم الدالة هنا بحذف الشرطة السفلية الزائدة
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *targets = @[@"Logs", @"ReportData", @"Pandora", @"crash_reports", @"TP3_Internal"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (NSString *folder in targets) {
        if (docPath) [fm removeItemAtPath:[docPath stringByAppendingPathComponent:folder] error:nil];
        if (cachePath) [fm removeItemAtPath:[cachePath stringByAppendingPathComponent:folder] error:nil];
    }
}

void ActivateAutoProtection() {
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        Method origMethod = class_getInstanceMethod(devClass, @selector(identifierForVendor));
        IMP newImp = class_getMethodImplementation([GeminiAutoShield class], @selector(newIDFV));
        method_setImplementation(origMethod, newImp);
    }

    NSArray *classes = @[@"FIRAnalytics", @"GSDKUMManager", @"MSAnalytics", @"TencentAnalytics", @"BeaconReport"];
    for (NSString *clsName in classes) {
        Class cls = objc_getClass([clsName UTF8String]);
        if (cls) {
            SEL sel = sel_registerName("logEventWithName:parameters:");
            Method m = class_getInstanceMethod(cls, sel);
            if (m) {
                method_setImplementation(m, class_getMethodImplementation([GeminiAutoShield class], @selector(stopAnalytics:)));
            }
        }
    }
}

__attribute__((constructor)) static void initialize() {
    // تأخير صامت 45 ثانية لتخطي حماية الإقلاع
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(45 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ActivateAutoProtection();
        
        // مؤقت تنظيف سجلات الباند كل 3 دقائق
        NSTimer *timer = [NSTimer timerWithTimeInterval:180.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            CleanEndGameLogs();
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    });
}
