#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// --- [كلاس الحماية المستقل] ---
@interface GeminiPure : NSObject
@end

@implementation GeminiPure

// تزييف معرف الجهاز لمنع الباند الغيابي
- (id)newIDFV {
    return [[NSUUID alloc] initWithUUIDString:@"A123E456-B789-4C0D-1E2F-3G4H5I6J7K8L"];
}

// تزييف معرف التطبيق لمنع كشف التعديل (حماية الأيمبوت)
- (NSString *)newBundleID {
    return @"com.tencent.ig";
}

@end

// --- [محرك الحقن الأصيل] ---
void runNativeBypass() {
    // 1. هوك IDFV
    Class deviceClass = objc_getClass("UIDevice");
    if (deviceClass) {
        Method orig = class_getInstanceMethod(deviceClass, @selector(identifierForVendor));
        Method swiz = class_getInstanceMethod([GeminiPure class], @selector(newIDFV));
        method_exchangeImplementations(orig, swiz);
    }

    // 2. هوك BundleID
    Class bundleClass = [NSBundle class];
    if (bundleClass) {
        Method origB = class_getInstanceMethod(bundleClass, @selector(bundleIdentifier));
        Method swizB = class_getInstanceMethod([GeminiPure class], @selector(newBundleID));
        method_exchangeImplementations(origB, swizB);
    }
}

%ctor {
    // انتظار 100 ثانية لضمان استقرار اللعبة تماماً وتخطي الفحص الأولي
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        runNativeBypass();
    });
}
