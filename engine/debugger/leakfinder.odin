package debugger

import "core:mem"
import "core:fmt"


leak_tracker: mem.Tracking_Allocator

initialize_tracker :: proc() -> mem.Allocator{
    mem.tracking_allocator_init(&leak_tracker, context.allocator)
    return mem.tracking_allocator(&leak_tracker)
}

print_unfreed_data ::proc(msg:string){
    fmt.println(msg, leak_tracker.total_memory_allocated-leak_tracker.total_memory_freed)
}

terminate_tracker ::proc(){
    if len(leak_tracker.allocation_map) > 0 {
        fmt.eprintf("=== %v allocations not freed: ===\n", len(leak_tracker.allocation_map))
        for _, entry in leak_tracker.allocation_map {
            fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
        }
    }
    if len(leak_tracker.bad_free_array) > 0 {
        fmt.eprintf("=== %v incorrect frees: ===\n", len(leak_tracker.bad_free_array))
        for entry in leak_tracker.bad_free_array {
            fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
        }
    }
    mem.tracking_allocator_destroy(&leak_tracker)
}