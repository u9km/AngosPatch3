#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <libkern/OSCacheControl.h>
#import <dlfcn.h>

// دالة الكتابة الآمنة
void GeminiStableWrite(uintptr_t address, uint32_t data) {
    if (address == 0) return;
    mach_port_t task = mach_task_self();
    vm_size_t size = sizeof(data);
    kern_return_t kr = vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr == KERN_SUCCESS) {
        *(uint32_t *)address = data;
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        sys_icache_invalidate((void *)address, size);
    }
}

// تفعيل الحماية في الخلفية
void ExecuteShield() {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
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
        uintptr_t idfv = (uintptr_t)dlsym(RTLD_DEFAULT, "UIDevice.identifierForVendor");
        if (idfv) GeminiStableWrite(idfv, 0xD65F03C0);
    });
}

// عرض القائمة بطريقة متوافقة مع iOS 13+
void ShowGreenMenu() {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    window = scene.windows.firstObject;
                    break;
                }
            }
        } else {
            window = [UIApplication sharedApplication].keyWindow;
        }

        if (window && window.rootViewController) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"GEMINI GUARD" message:@"Protection Ready" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *act = [UIAlertAction actionWithTitle:@"ACTIVATE" style:UIAlertActionStyleDefault handler:^(UIAlertAction * a) { ExecuteShield(); }];
            [act setValue:[UIColor systemGreenColor] forKey:@"titleTextColor"];
            [alert addAction:act];
            [window.rootViewController presentViewController:alert animated:YES completion:nil];
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ ShowGreenMenu(); });
        }
    });
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ShowGreenMenu();
    });
}

