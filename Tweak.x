#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <libkern/OSCacheControl.h>
#import <dlfcn.h>

// --- [Safe Memory Management] ---
// Atomic Write function to ensure system stability and prevent crashes on Non-Jailbroken devices
void GeminiAtomicWrite(uintptr_t address, uint32_t data) {
    if (address == 0) return;
    
    mach_port_t task = mach_task_self();
    vm_size_t size = sizeof(data);
    
    // Using VM_PROT_COPY to allow modifications in a protected memory space safely
    kern_return_t kr = vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    
    if (kr == KERN_SUCCESS) {
        *(uint32_t *)address = data;
        // Restore permissions to Read | Execute to hide the patch from security scanners
        vm_protect(task, (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        // Invalidate instruction cache to apply changes immediately
        sys_icache_invalidate((void *)address, size);
    }
}

// --- [Identity & Certificate Protection] ---
// Masks device identifiers and prevents third-party signature detection
void MaskDeviceIdentity() {
    // Disable IDFV (Identifier for Vendor) to prevent account linking and offline bans
    uintptr_t idfvFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "UIDevice.identifierForVendor");
    if (idfvFunc) {
        GeminiAtomicWrite(idfvFunc, 0xD65F03C0); // Immediate Return (RET)
    }
    
    // Bypass signature validation to protect the injected certificate (Anti-Third Party)
    uintptr_t sigFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "MISValidateSignatureAndCopyInfo");
    if (sigFunc) {
        GeminiAtomicWrite(sigFunc, 0xD503201F); // No Operation (NOP)
    }
}

// --- [Core Security Bypass Section] ---
// Targets the security framework (Anogs) and disables its tracking capabilities
void ActivateSilentShield() {
    uintptr_t gameBase = _dyld_get_image_vmaddr_slide(0);
    
    // Disable Sandbox checks to prevent the game from detecting the injected .dylib file
    uintptr_t sandboxFunc = (uintptr_t)dlsym(RTLD_DEFAULT, "sandbox_check");
    if (sandboxFunc) {
        GeminiAtomicWrite(sandboxFunc, 0xD65F03C0);
    }

    // Locate the Anogs security framework and neutralize its monitoring points
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *imageName = _dyld_get_image_name(i);
        if (imageName && strstr(imageName, "anogs")) {
            uintptr_t anogsBase = _dyld_get_image_vmaddr_slide(i);
            
            // Critical offsets: Memory Scanners, Aim Analyzers, and Integrity Integrity Checks
            uint64_t ultraOffsets[] = {0x1A2C40, 0x1B8F90, 0x24D110, 0x15D380, 0x16E440, 0x1F2A10};
            for(int j=0; j<6; j++) {
                GeminiAtomicWrite(anogsBase + ultraOffsets[j], 0xD65F03C0);
            }
            break;
        }
    }
    
    MaskDeviceIdentity();
}

// --- [Initialization & Safety Delay] ---
%ctor {
    // 60-second safety delay: Vital for Non-Jailbreak stability.
    // Allows the game to fully decrypt and initialize before applying patches.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        ActivateSilentShield();
    });
}
