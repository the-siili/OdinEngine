package graphics

import d "../definition"
import m "core:math"

@private
render_objects : map[d.RenderObjectId]^RenderObject
@private
next_render_object_index : d.RenderObjectId = 0

@private
render_object_hierarchy : map[d.ShaderId]map[d.MaterialId][dynamic]d.RenderObjectId

@private
RenderObject :: struct{
    mesh_index : i32,
    location : [3]f32,
    rotation : [3]f32,
    scale : [3]f32,
    material : d.MaterialId
}

create_render_object :: proc(mesh_index : i32, material : d.MaterialId, position: [3]f32={0, 0, 0}, rotation : [3]f32={0, 0, 0}, scale : [3]f32 = {1, 1, 1}) -> d.RenderObjectId{

    renderObject := new(RenderObject)
    renderObject.mesh_index = mesh_index
    renderObject.location = position
    renderObject.rotation = rotation
    renderObject.scale = scale
    renderObject.material = material

    render_objects[next_render_object_index] = renderObject
    shader_hierarchy := render_object_hierarchy[materials[material].shader]

    render_object_hierarchy_array := shader_hierarchy[material]
    append(&render_object_hierarchy_array, next_render_object_index)

    shader_hierarchy[material] = render_object_hierarchy_array
    defer next_render_object_index += 1
    return next_render_object_index
}

remove_render_object :: proc(render_object_id : d.RenderObjectId){
    free(render_objects[render_object_id])
    delete_key(&render_objects, render_object_id)
}

remove_all_render_objects :: proc(){
    for id in render_objects{
        free(render_objects[id])
        delete_key(&render_objects, id)
    }
}

set_render_object_position:: proc(render_object_id : d.RenderObjectId, position : [3]f32){
    render_objects[render_object_id].location = position
}

set_render_object_rotation:: proc(render_object_id : d.RenderObjectId, rotation : [3]f32){
    render_objects[render_object_id].rotation = rotation
}

set_render_object_scale:: proc(render_object_id : d.RenderObjectId, scale : [3]f32){
    render_objects[render_object_id].scale= scale
}

set_render_object_transform:: proc(render_object_id : d.RenderObjectId,  position : [3]f32, rotation : [3]f32, scale : [3]f32){
    render_objects[render_object_id].location = position
    render_objects[render_object_id].rotation = rotation
    render_objects[render_object_id].scale= scale
}

@private
make_model_matrix :: proc(position, scale, rotation: [3]f32) -> [16]f32 {
    cx := m.cos_f32(rotation.x)
    sx := m.sin_f32(rotation.x)

    cy := m.cos_f32(rotation.y)
    sy := m.sin_f32(rotation.y)

    cz := m.cos_f32(rotation.z)
    sz := m.sin_f32(rotation.z)

    rotation_x := [16]f32 {
        1,  0,  0, 0,
        0, cx, sx, 0,
        0, -sx, cx, 0,
        0,  0,  0, 1,
    }

    rotation_y := [16]f32 {
        cy, 0, -sy, 0,
        0, 1,  0, 0,
        sy, 0,  cy, 0,
        0, 0,  0, 1,
    }

    rotation_z := [16]f32 {
        cz, sz, 0, 0,
        -sz, cz, 0, 0,
        0,  0, 1, 0,
        0,  0, 0, 1,
    }

    rotation_mat := mat4_mul(rotation_x, rotation_y)
    rotation_mat = mat4_mul(rotation_mat , rotation_z)

    return [16]f32 {
        rotation_mat[0] * scale.x,
        rotation_mat[1] * scale.x,
        rotation_mat[2] * scale.x,
        0,

        rotation_mat[4] * scale.y,
        rotation_mat[5] * scale.y,
        rotation_mat[6] * scale.y,
        0,

        rotation_mat[8] * scale.z,
        rotation_mat[9] * scale.z,
        rotation_mat[10] * scale.z,
        0,

        position.x,
        position.y,
        position.z,
        1,
    }
}
