#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <substrate.h>

// تعريف لتخزين الدالة الأصلية
static id (*orig_idfv)(id self, SEL _cmd);

// دالة الهوك الجديدة (تزييف الهوية)
id hooked_idfv(id self, SEL _cmd) {
    // إرجاع معرف وهمي ثابت يمنع السيرفر من التعرف على جهازك المحظور
    return @"A721B1A8-D49C-4B1E-92FC-0C347A2E7F6B";
}

// دالة التنفيذ الآمن
void ExecuteProtection() {
    // البحث عن الكلاس بهدوء دون التسبب في انهيار (objc_lookUpClass)
    Class deviceClass = objc_lookUpClass("UIDevice");
    if (deviceClass) {
        SEL idfvSelector = sel_registerName("identifierForVendor");
        // تبديل الرسائل (Method Swizzling) بدلاً من تعديل بايتات الذاكرة
        MSHookMessageEx(deviceClass, idfvSelector, (IMP)hooked_idfv, (IMP *)&orig_idfv);
    }
}

%ctor {
    // السر في منع الكراش: الانتظار الطويل وتغيير الخيط (Thread)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        // انتظار 100 ثانية لضمان استقرار اللعبة تماماً وتخطي فحوصات البداية
        [NSThread sleepForTimeInterval:100.0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            ExecuteProtection();
        });
    });
}
