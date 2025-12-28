#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface GeminiAutoShield : NSObject
@end

@implementation GeminiAutoShield

// توليد UUID جديد لكل جلسة لعب لمنع تتبع الجهاز
+ (NSString *)generateRandomUUID {
    return [[NSUUID UUID] UUIDString];
}

// تزويد النظام بالمعرف العشوائي بدلاً من الحقيقي
- (id)newIDFV {
    return [[NSUUID alloc] initWithUUIDString:[GeminiAutoShield generateRandomUUID]];
}

// تعطيل التحليلات وإرسال التقارير نهائياً
- (void)stopAnalytics:(id)arg1 { return; }

@end

// دالة تنظيف الملفات (حماية نهاية الجيم) - تعمل في الخلفية
void CleanEndGameLogs() {
    NSString *docPath = [NSSearchPathForDirectories_InDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSArray *targets = @[@"Logs", @"ReportData", @"Pandora", @"crash_reports", @"TP3_Internal"];
    NSFileManager *fm = [NSFileManager defaultManager];
    
    for (NSString *folder in targets) {
        [fm removeItemAtPath:[docPath stringByAppendingPathComponent:folder] error:nil];
        [fm removeItemAtPath:[cachePath stringByAppendingPathComponent:folder] error:nil];
    }
}

void ActivateAutoProtection() {
    // 1. هوك الهوية (IDFV)
    Class devClass = objc_getClass("UIDevice");
    if (devClass) {
        Method origMethod = class_getInstanceMethod(devClass, @selector(identifierForVendor));
        IMP newImp = class_getMethodImplementation([GeminiAutoShield class], @selector(newIDFV));
        method_setImplementation(origMethod, newImp);
    }

    // 2. معطل التقارير والتحليلات (بما فيها تحليلات تينسنت)
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

// مشغل الحقن الصامت
__attribute__((constructor)) static void initialize() {
    // تأخير طويل (45 ثانية) لضمان دخول اللعبة وتخطي كافة الفحوصات الأمنية عند الإقلاع
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(45 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        ActivateAutoProtection();
        
        // تنظيف دوري صامت كل 3 دقائق لمسح سجلات الباند
        NSTimer *timer = [NSTimer timerWithTimeInterval:180.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
            CleanEndGameLogs();
        }];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        
        NSLog(@"[VIP] SILENT PROTECTION ACTIVE.");
    });
}

