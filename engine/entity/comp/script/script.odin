#+feature dynamic-literals
package script

import "core:fmt"
import d "../../../definition"



Script :: struct {
    start: proc(entity: d.Entity, data: rawptr),
    update: proc(entity: d.Entity, data: rawptr),
    fixed_update: proc(entity: d.Entity, data: rawptr),
    terminate: proc(entity: d.Entity, data: rawptr),
    data: rawptr
}


scripts : map[d.Entity]^Script = {}



start :: proc() {
    for entity in scripts{
        scripts[entity].start(entity, scripts[entity].data)
    }
}
update :: proc() {

    for entity in scripts{
        scripts[entity].update(entity, scripts[entity].data)
    }

}
fixed_update :: proc() {
    for entity in scripts{
        scripts[entity].fixed_update(entity, scripts[entity].data)
    }

}
terminate :: proc() {

    for entity in scripts{
        scripts[entity].terminate(entity, scripts[entity].data)
        sc := scripts[entity]
        mem_free(sc.data)
        mem_free(sc)
    }

    clear(&scripts)
}


add :: proc(entity : d.Entity, script : ^Script) {
    scripts[entity] = script
}