#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>
#import <substrate.h>
#import <sys/stat.h>
#import <sys/utsname.h>

// --- [تخزين الدوال الأصلية لضمان الاستقرار] ---
static id (*orig_idfv)(UIDevice *self, SEL _cmd);
static int (*orig_access)(const char *path, int mode);
static int (*orig_stat)(const char *path, struct stat *buf);
static int (*orig_uname)(struct utsname *name);
static NSString* (*orig_advertisingIdentifier)(id self, SEL _cmd);

// --- [دوال الحماية المطورة - Ultimate Hooks] ---

// 1. تزييف موديل الجهاز (iPhone 15 Pro Max) لمنع تتبع الهاردوير
int hooked_uname(struct utsname *name) {
    int ret = orig_uname(name);
    strcpy(name->machine, "iPhone16,2"); 
    return ret;
}

// 2. درع الباند الغيابي: تزييف معرفات الجهاز (IDFV & IDFA)
id hooked_idfv(UIDevice *self, SEL _cmd) {
    return @"A8B7C6D5-E4F3-2G1H-0I9J-K8L7M6N5O4P3"; // معرف وهمي ثابت
}

NSString* hooked_ad_id(id self, SEL _cmd) {
    return @"00000000-0000-0000-0000-000000000000"; // تصفير معرف الإعلانات
}

// 3. حماية اللوبي: إخفاء ملفات الحقن وشهادات التوقيع (Esign/Sideloadly)
int hooked_access(const char *path, int mode) {
    if (path != NULL) {
        if (strstr(path, "Library/MobileSubstrate") || 
            strstr(path, "dylib") || 
            strstr(path, "Signer") || 
            strstr(path, "Prov") || 
            strstr(path, "Cydia") ||
            strstr(path, "Shadow") ||
            strstr(path, ".deb")) {
            return -1; // إخفاء تام
        }
    }
    return orig_access(path, mode);
}

// 4. هوك فحص حالة الملفات لمنع كشف الـ "Side-Loading"
int hooked_stat(const char *path, struct stat *buf) {
    if (path != NULL && (strstr(path, "dylib") || strstr(path, "Substrate") || strstr(path, "Frameworks/App.framework"))) {
        return -1;
    }
    return orig_stat(path, buf);
}

// --- [محرك تفعيل الحماية الذكي] ---

void EngageUltimateShield() {
    // هوك الدوال النظامية (System APIs)
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "access"), (void *)hooked_access, (void **)&orig_access);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "stat"), (void *)hooked_stat, (void **)&orig_stat);
    MSHookFunction((void *)dlsym(RTLD_DEFAULT, "uname"), (void *)hooked_uname, (void **)&orig_uname);
    
    // هوك Objective-C (بصمة الجهاز)
    MSHookMessageEx([UIDevice class], @selector(identifierForVendor), (IMP)hooked_idfv, (IMP *)&orig_idfv);
    
    // محاولة هوك معرف الإعلانات إذا كانت اللعبة تستخدمه للكشف
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL advertisingIdentifierSel = NSSelectorFromString(@"advertisingIdentifier");
        MSHookMessageEx(ASIdentifierManagerClass, advertisingIdentifierSel, (IMP)hooked_ad_id, (IMP *)&orig_advertisingIdentifier);
    }

    NSLog(@"[Gemini] Ultimate Protection Engaged. No-Jailbreak Mode Active.");
}

// --- [واجهة المستخدم الحديثة باللون الأخضر] ---

void ShowUltimateMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        }
        if (!window) window = [UIApplication sharedApplication].keyWindow;

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GEMINI ULTIMATE" 
                                                                           message:@"Anti-Ban & Anti-Crash System" 
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *activate = [UIAlertAction actionWithTitle:@"START GREEN PROTECTION" 
                                                               style:UIAlertActionStyleDefault 
                                                             handler:^(UIAlertAction * action) {
                EngageUltimateShield();
            }];
            
            [activate setValue:[UIColor colorWithRed:0.0 green:0.8 blue:0.0 alpha:1.0] forKey:@"titleTextColor"];
            [alert addAction:activate];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ ShowUltimateMenu(); });
        }
    });
}

%ctor {
    // تأخير التفعيل لـ 60 ثانية لضمان استقرار محرك اللعبة تماماً وتخطي الفحص الأولي
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ShowUltimateMenu();
    });
}
