#+feature dynamic-literals
package graphics

import "core:fmt"



CreatePlane :: proc(w : f32=1, d : f32=1) -> (o_vertices:[]f32, o_indices : []u32){

    vertices: [dynamic]f32 
    vertices = {
        -0.5*w, 0.0, -0.5*d, 0, 0, 0, 1, 0,
        0.5*w, 0.0, -0.5*d, 1, 0, 0, 1, 0,
        -0.5*w, 0.0, 0.5*d, 0, 1, 0, 1, 0,
        0.5*w, 0.0, 0.5*d, 1, 1, 0, 1, 0,
    }
    indices: [dynamic]u32 
    indices = {
        0,1,2,
        1,2,3
    }
    return vertices[:], indices[:]

}