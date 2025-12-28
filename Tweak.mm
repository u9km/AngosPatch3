#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <mach-o/dyld.h>

#define CRYPTO_KEY 0xAD

@interface SecurityModule : NSObject
- (id)v_id;
@end

@implementation SecurityModule
- (id)v_id { return [[NSUUID UUID] UUIDString]; }
@end

// دالة فك التشفير اللحظي
NSString* obs_decode(int* data, int len) {
    char* out = (char*)malloc(len + 1);
    for(int i=0; i<len; i++) out[i] = data[i] ^ CRYPTO_KEY;
    out[len] = '\0';
    NSString* res = [NSString stringWithUTF8String:out];
    free(out);
    return res;
}

// دالة الانتحار البرمجي عند كشف الفحص
void TriggerSelfDestruct() {
    // حذف ملفات السجلات فوراً قبل الإغلاق
    NSString *logPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ShadowTrackerExtra/Saved/Logs"];
    [[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
    
    // إغلاق اللعبة فوراً لإيقاف عملية الكشف
    exit(0); 
}

// مراقب الذاكرة (Memory Watcher)
void MonitorAppIntegrity() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        // إذا تم حقن مكتبة غريبة غير مكتبتنا المشفرة أثناء اللعب
        if (strstr(name, "Frida") || strstr(name, "CydiaSubstrate")) {
            TriggerSelfDestruct();
        }
    }
}

void StealthCleanup() {
    NSString *root = NSHomeDirectory();
    NSFileManager *fm = [NSFileManager defaultManager];
    int c1[] = {173, 206, 202, 210, 192, 211, 216, 172, 218, 201, 192, 205, 206, 214, 189, 211, 192, 194, 202, 204, 211, 196, 217, 211, 192, 172, 218, 192, 215, 196, 197, 172, 205, 206, 198, 210};
    
    NSArray *paths = @[[root stringByAppendingPathComponent:obs_decode(c1, 36)], @"tmp"];
    for (NSString *p in paths) [fm removeItemAtPath:p error:nil];
}

__attribute__((constructor)) static void framework_entry() {
    StealthCleanup();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // تفعيل مراقب الذاكرة
        [NSTimer scheduledTimerWithTimeInterval:5.0 repeats:YES block:^(NSTimer *timer) {
            MonitorAppIntegrity();
        }];

        // تزييف الهوية
        Method m1 = class_getInstanceMethod([UIDevice class], @selector(identifierForVendor));
        method_setImplementation(m1, imp_implementationWithBlock(^(id self) {
            return [[NSUUID alloc] initWithUUIDString:[[SecurityModule alloc] v_id]];
        }));

        [NSTimer scheduledTimerWithTimeInterval:12.0 repeats:YES block:^(NSTimer *timer) {
            StealthCleanup();
        }];
    });
}
