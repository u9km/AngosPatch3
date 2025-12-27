#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <libkern/OSCacheControl.h>
#import <dlfcn.h>

// --- [Safe Memory Write] ---
void GeminiAtomicWrite(uintptr_t address, uint32_t data) {
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

// --- [Identity Protection] ---
void MaskDeviceIdentity() {
    uintptr_t idfvFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "UIDevice.identifierForVendor");
    if (idfvFunc) GeminiAtomicWrite(idfvFunc, 0xD65F03C0);
    
    uintptr_t sigFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "MISValidateSignatureAndCopyInfo");
    if (sigFunc) GeminiAtomicWrite(sigFunc, 0xD503201F);
}

// --- [Security Bypass] ---
void ActivateSilentShield() {
    uintptr_t sandboxFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "sandbox_check");
    if (sandboxFunc) GeminiAtomicWrite(sandboxFunc, 0xD65F03C0);

    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "anogs")) {
            uintptr_t anogsBase = _dyld_get_image_vmaddr_slide(i);
            uint64_t offsets[] = {0x1A2C40, 0x1B8F90, 0x24D110, 0x15D380, 0x16E440, 0x1F2A10};
            for(int j=0; j<6; j++) {
                GeminiAtomicWrite(anogsBase + offsets[j], 0xD65F03C0);
            }
            break;
        }
    }
    MaskDeviceIdentity();
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ActivateSilentShield();
    });
}
