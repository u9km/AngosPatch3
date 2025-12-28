#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <dlfcn.h>

@interface BlackAmarShield : NSObject
- (id)fetchNewID;
- (void)silentMode;
@end

@implementation BlackAmarShield
- (id)fetchNewID {
    return [[NSUUID UUID] UUIDString];
}
- (void)silentMode { return; }
@end

void GlobalPurge() {
    NSString *home = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *paths = @[
        @"Library/Caches/com.tencent.ig",
        @"Library/Logs",
        @"Documents/ShadowTrackerExtra/Saved/Logs",
        @"Documents/ShadowTrackerExtra/Saved/StatCache",
        @"Documents/ShadowTrackerExtra/Saved/CloudStorage",
        @"tmp"
    ];
    for (NSString *p in paths) {
        [fm removeItemAtPath:[home stringByAppendingPathComponent:p] error:nil];
    }
}

__attribute__((constructor)) static void core_entry() {
    // تنظيف أولي صامت قبل بدء الجلسة
    GlobalPurge();

    // تم تعديل التأخير هنا ليكون 10 ثوانٍ فقط بناءً على طلبك
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // تزييف الهوية والنظام
        Method idfv = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
        method_setImplementation(idfv, imp_implementationWithBlock(^(id self) {
            return [[NSUUID alloc] initWithUUIDString:[[BlackAmarShield alloc] fetchNewID]];
        }));

        Method ver = class_getInstanceMethod([UIDevice class], @selector(systemVersion));
        method_setImplementation(ver, imp_implementationWithBlock(^(id self) {
            return @"12.1"; 
        }));

        // مؤقت تنظيف دوري كل 15 ثانية لمواجهة الحماية
        [NSTimer scheduledTimerWithTimeInterval:15.0 repeats:YES block:^(NSTimer *timer) {
            GlobalPurge();
        }];
        
        NSLog(@"[BLACK AMAR] PROTECTION ACTIVE - 10s DELAY APPLIED.");
    });
}
