#import <Foundation/Foundation.h>
#import <mach/mach.h>
#import <mach-o/dyld.h>
#import <libkern/OSCacheControl.h>

#ifdef __cplusplus
extern "C" {
#endif
    kern_return_t vm_remap(vm_map_t, vm_address_t *, vm_size_t, vm_address_t, int, vm_map_t, vm_address_t, boolean_t, vm_prot_t *, vm_prot_t *, vm_inherit_t);
#ifdef __cplusplus
}
#endif

// Target Image Names
#define ANOGS_IMAGE "anogs"
#define ARM64_RET 0xD65F03C0

// Core Logic for Stealth Writing
bool StealthRemapWrite(uintptr_t address, uint32_t data) {
    mach_port_t task = mach_task_self();
    vm_address_t page_start = trunc_page(address);
    vm_size_t page_size = vm_page_size;
    uintptr_t offset_in_page = address - page_start;

    vm_address_t temp_page;
    if (vm_allocate(task, &temp_page, page_size, VM_FLAGS_ANYWHERE) != KERN_SUCCESS)
        return false;

    memcpy((void*)temp_page, (void*)page_start, page_size);
    *(uint32_t*)(temp_page + offset_in_page) = data;

    vm_protect(task, temp_page, page_size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);

    vm_prot_t cur_prot, max_prot;
    kern_return_t kr = vm_remap(task, &page_start, page_size, 0, VM_FLAGS_OVERWRITE, 
                                task, temp_page, TRUE, &cur_prot, &max_prot, VM_INHERIT_NONE);

    vm_deallocate(task, temp_page, page_size);
    sys_icache_invalidate((void *)address, 4);

    return (kr == KERN_SUCCESS);
}

uintptr_t GetImageSlide(const char* imageName) {
    for (uint32_t i = 0; i < _dyld_image_count(); i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, imageName)) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

// Logic to bypass anogs security
void ApplyAnogsBypass() {
    uintptr_t anogsBase = GetImageSlide(ANOGS_IMAGE);
    if (anogsBase > 0) {
        // These are generic security bypass points for anogs framework
        // They target detection loops and environment checks
        uint64_t bypassOffsets[] = {0x1A2C40, 0x1B8F90, 0x24D110, 0x15D380}; 
        
        for (int i = 0; i < 4; i++) {
            StealthRemapWrite(anogsBase + bypassOffsets[i], ARM64_RET);
        }
    }
}

%ctor {
    // 25 Seconds delay to ensure the game engine and anogs are fully initialized
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ApplyAnogsBypass();
    });
}
