#import <Foundation/Foundation.h>
#include <mach-o/dyld.h>
#include <mach/mach.h>
#include <libkern/OSCacheControl.h>

// تعريف ضروري لعمل الكود
#define CFSwapInt32(x) (uint32_t)((((x) & 0xFF000000) >> 24) | (((x) & 0x00FF0000) >> 8) | (((x) & 0x0000FF00) << 8) | (((x) & 0x000000FF) << 24))

static uintptr_t get_base_address() {
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (name && strstr(name, "ShadowTrackerExtra")) {
            return _dyld_get_image_vmaddr_slide(i);
        }
    }
    return 0;
}

void apply_memory_patch(uintptr_t address, uint32_t data) {
    if (address == 0) return;
    size_t size = sizeof(data);
    kern_return_t kr = vm_protect(mach_task_self(), (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_WRITE | VM_PROT_COPY);
    if (kr == KERN_SUCCESS) {
        *(uint32_t *)address = data;
        vm_protect(mach_task_self(), (vm_address_t)address, size, FALSE, VM_PROT_READ | VM_PROT_EXECUTE);
        sys_icache_invalidate((void *)address, size);
    }
}

static const uint64_t patch_offsets[] = {
    0x1b7404, 0xaa738, 0xAA550, 0x4A594, 0x76CC4, 0x82C8C, 0x90488, 0x905D8, 
    0x94E34, 0xADCDC, 0x57F98, 0x583E4, 0x5F7D4, 0x5FF64, 0x1EDF8C, 0x1e094, 
    0x1E06C, 0x320B4, 0x239A4, 0x3a174, 0x42690, 0x426cc, 0x95458, 0xb3030, 
    0x44e24, 0x45E8C, 0x45DBC, 0x45CEC, 0x45B20, 0x45804, 0x458A4, 0x151778
};

#define PATCH_INST CFSwapInt32(0xC0035FD6)

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        uintptr_t slide = get_base_address();
        if (slide > 0) {
            size_t count = sizeof(patch_offsets) / sizeof(patch_offsets[0]);
            for (size_t i = 0; i < count; i++) {
                apply_memory_patch(slide + patch_offsets[i], PATCH_INST);
            }
        }
    });
}

