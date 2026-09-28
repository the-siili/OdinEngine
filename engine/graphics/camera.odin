package graphics

import m "core:math"

far :: 1000
near :: 0.01
fov :: 70

@private
aspect : f32

camera_location : [3]f32 = {0, 0, 8}
camera_rotation : [3]f32 = {0, 0, 0}

@private
perspective_mat : [16]f32

@private
make_view_matrix :: proc(position, rotation: [3]f32) -> [16]f32 {
    
    translation := [16]f32 {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        -position.x, -position.y, -position.z, 1,
    }
    
    cx := m.cos_f32(rotation.x)
    sx := m.sin_f32(rotation.x)

    cy := m.cos_f32(rotation.y)
    sy := m.sin_f32(rotation.y)

    cz := m.cos_f32(rotation.z)
    sz := m.sin_f32(rotation.z)

    rx := [16]f32 {
        1, 0,  0, 0,
        0, cx, -sx, 0,
        0, sx, cx, 0,
        0, 0,  0, 1,
    }

    ry := [16]f32 {
        cy, 0, sy, 0,
        0,  1, 0,  0,
        -sy, 0, cy, 0,
        0, 0,  0, 1,
    }

    rz := [16]f32 {
        cz, -sz, 0, 0,
        sz,  cz, 0, 0,
        0,   0,  1, 0,
        0,   0,  0, 1,
    }

    rotation_mat := mat4_mul(rz, ry)
    rotation_mat = mat4_mul(rotation_mat, rx)

    //rotation_mat[12] = -position.x
    //rotation_mat[13] = -position.y
    //rotation_mat[14] = -position.z

    return mat4_mul(rotation_mat, translation)
}
