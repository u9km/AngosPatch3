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

#define ANOGS_IMAGE "anogs"
#define GAME_IMAGE "ShadowTrackerExtra"
#define ARM64_RET 0xD65F03C0

typedef struct {
    uint64_t offset;
} PatchData;

static const PatchData gamePatches[] = {
    {0x1b7404}, {0xaa738}, {0xAA550}, {0x4A594}, {0x76CC4}, {0x82C8C}, 
    {0x90488}, {0x905D8}, {0x94E34}, {0xADCDC}, {0x57F98}, {0x583E4}, 
    {0x5F7D4}, {0x5FF64}, {0x1EDF8C}, {0x1e094}, {0x1E06C}, {0x320B4}, 
    {0x239A4}, {0x3a174}, {0x42690}, {0x426cc}, {0x95458}, {0xb3030}, 
    {0x44e24}, {0x45E8C}, {0x45DBC}, {0x45CEC}, {0x45B20}, {0x45804}, 
    {0x458A4}, {0x151778}
};

static const PatchData securityBypasses[] = {
    {0x1A2C40}, {0x1B8F90}, {0x24D110}, {0x15D380}
};

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

void ExecuteAdvancedBypass() {
    uintptr_t anogsBase = GetImageSlide(ANOGS_IMAGE);
    if (anogsBase > 0) {
        for (int i = 0; i < 4; i++) {
            StealthRemapWrite(anogsBase + securityBypasses[i].offset, ARM64_RET);
        }
    }

    [NSThread sleepForTimeInterval:0.5];

    uintptr_t gameBase = GetImageSlide(GAME_IMAGE);
    if (gameBase > 0) {
        size_t count = sizeof(gamePatches) / sizeof(PatchData);
        for (size_t i = 0; i < count; i++) {
            StealthRemapWrite(gameBase + gamePatches[i].offset, ARM64_RET);
        }
    }
}

%ctor {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(25 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        ExecuteAdvancedBypass();
    });
}
