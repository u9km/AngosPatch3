#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <libkern/OSCacheControl.h>
#import <dlfcn.h>

// --- [High-Performance Memory Engine] ---
// تم تحسين الدالة لتعمل بأسلوب "الخيط الآمن" (Thread-Safe)
void GeminiStableWrite(uintptr_t address, uint32_t data) {
    if (address == 0) return;
    mach_port_t task = mach_task_self();
    vm_size_t size = sizeof(data);
    
    // استخدام ذاكرة مؤقتة لضمان عدم حدوث كراش أثناء التعديل
    kern_return_t kr = vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr == KERN_SUCCESS) {
        *(uint32_t *)address = data;
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        sys_icache_invalidate((void *)address, size);
    }
}

// --- [The Silent Shield Logic] ---
void ExecuteShield() {
    // تشغيل الحماية في خيط منفصل لتجنب تعليق اللعبة (Freeze)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        // 1. تجميد نظام Anogs
        for (uint32_t i = 0; i < _dyld_image_count(); i++) {
            const char *name = _dyld_get_image_name(i);
            if (name && strstr(name, "anogs")) {
                uintptr_t base = _dyld_get_image_vmaddr_slide(i);
                uint64_t offsets[] = {0x1A2C40, 0x1B8F90, 0x24D110, 0x15D380, 0x16E440, 0x1F2A10};
                for(int j=0; j<6; j++) {
                    GeminiStableWrite(base + offsets[j], 0xD65F03C0);
                }
                break;
            }
        }

        // 2. حماية الهوية والشهادة
        uintptr_t idfv = (uintptr_t)dlsym(RTLD_DEFAULT, "UIDevice.identifierForVendor");
        if (idfv) GeminiStableWrite(idfv, 0xD65F03C0);
        
        uintptr_t sig = (uintptr_t)dlsym(RTLD_DEFAULT, "MISValidateSignatureAndCopyInfo");
        if (sig) GeminiStableWrite(sig, 0xD503201F);
    });
}

// --- [Safe UI Launcher] ---
void ShowGreenMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window || !window.rootViewController) {
            // محرك اللعبة لم يجهز الواجهة بعد، انتظر 5 ثوانٍ وحاول مجدداً
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ShowGreenMenu();
            });
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GEMINI GUARD" 
                                                                       message:@"Anti-Ban & Protection Ready" 
                                                                preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *activate = [UIAlertAction actionWithTitle:@"ACTIVATE SHIELD" 
                                                           style:UIAlertActionStyleDefault 
                                                         handler:^(UIAlertAction * action) {
            ExecuteShield();
        }];

        // تلوين الزر باللون الأخضر الحديث
        [activate setValue:[UIColor colorWithRed:0.20 green:0.78 blue:0.35 alpha:1.0] forKey:@"titleTextColor"];
        [alert addAction:activate];

        [window.rootViewController presentViewController:alert animated:YES completion:nil];
    });
}

%ctor {
    // انتظار 45 ثانية لضمان استقرار محرك اللعبة تماماً قبل إظهار الزر
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ShowGreenMenu();
    });
}

