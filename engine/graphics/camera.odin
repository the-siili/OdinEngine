package graphics

import m "core:math"
import gl "vendor:OpenGL"
import d "../definition"
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
bg_vao : u32
@private
bg_vbo : u32
@private
bg_ebo : u32
@private
bg_texture : d.TextureId
@private
bg_shader : d.ShaderId
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

create_background :: proc(texture : d.TextureId, shader : d.ShaderId){
    bg_texture = texture
    bg_shader = shader
    // Set up vertex array / element array / buffer objects
    gl.GenVertexArrays(1, &bg_vao)
    gl.BindVertexArray(bg_vao)

    gl.GenBuffers(1, &bg_vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, bg_vbo)

    gl.GenBuffers(1, &bg_ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, bg_ebo)


    // Describe GPU buffer.
    gl.BufferData(gl.ARRAY_BUFFER,     // target
                  len(bg_vertices) * size_of(f32),   // size of the buffer object's data store
                  &bg_vertices,           // data used for initialization
                  gl.STATIC_DRAW)      // usage

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 
                    len(bg_indices)*size_of(u32), 
                    &bg_indices, 
                    gl.STATIC_DRAW)

    // Position and color attributes. Don't forget to enable!
    //vertices coords
    gl.VertexAttribPointer(0,                   // index
                           3,                   // size
                           gl.FLOAT,            // type
                           gl.FALSE,            // normalized
                           5 * size_of(f32),    // stride
                           0)                   // offset
    //uv
    gl.VertexAttribPointer(1,                   // index
                        2,                   // size
                        gl.FLOAT,            // type
                        gl.FALSE,            // normalized
                        5 * size_of(f32),    // stride
                        3 * size_of(f32))                // offset
    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)
}



render_background :: proc(perspective_ptr : [^] f32, view_ptr : [^] f32){
    gl.Disable(gl.DEPTH_TEST)
    gl.Disable(gl.POLYGON_SMOOTH);
    gl.Hint(gl.POLYGON_SMOOTH_HINT, gl.FASTEST);
    gl.UseProgram(shaders[bg_shader])

    gl.UniformMatrix4fv(gl.GetUniformLocation(shaders[bg_shader], "perspective_mat"), 1, gl.FALSE, perspective_ptr)
    gl.UniformMatrix4fv(gl.GetUniformLocation(shaders[bg_shader], "view_mat"), 1, gl.FALSE, view_ptr)

    gl.Uniform1i(gl.GetUniformLocation(shaders[bg_shader], "texture0"), 0)
    gl.ActiveTexture(gl.TEXTURE0); 
    gl.BindTexture(gl.TEXTURE_2D, textures[bg_texture]);

    gl.BindVertexArray(bg_vao)
    gl.DrawElements(
        gl.TRIANGLES,
        36,
        gl.UNSIGNED_INT,
        nil,
    )
    gl.Enable(gl.DEPTH_TEST)
}

bg_vertices : [6*4*5] f32 = {
    // front
    -1, -1, -1, 2.0/10.0, 1,
    1, -1, -1, 3.0/10.0, 1,
    -1, 1, -1, 2.0/10.0, 0,
    1, 1, -1, 3.0/10.0, 0,
    //back
    -1, -1, 1, 4.0/10.0, 1,
    1, -1, 1, 3.0/10.0, 1,
    -1, 1, 1, 4.0/10.0, 0,
    1, 1, 1, 3.0/10.0, 0,
    //left
    -1, -1, -1, 6.0/10.0, 1,
    -1, 1, -1, 6.0/10.0, 0,
    -1, -1, 1, 5.0/10.0, 1,
    -1, 1, 1, 5.0/10.0, 0,
    //right
    1, -1, -1, 4.0/10.0, 1,
    1, 1, -1, 4.0/10.0, 0,
    1, -1, 1, 5.0/10.0, 1,
    1, 1, 1, 5.0/10.0, 0,
    //bottom
    -1, -1, -1, 1.0/10.0, 0,
    1, -1, -1, 2.0/10.0, 0,
    -1, -1, 1, 1.0/10.0, 1,
    1, -1, 1, 2.0/10.0, 1,
    //top
    -1, 1, -1, 0, 1,
    1, 1, -1, 1.0/10.0, 1,
    -1, 1, 1, 0, 0,
    1, 1, 1, 1.0/10.0, 0
}

    
bg_indices : [3 * 2 * 6] u32 = {
    0,  1,   2,  
    1,  2,  3, // Face 1
    4,  5,   6,  
    5,  6,  7, // Face 2
    8,  9,  10,  
    9, 10, 11, // Face 3
    12, 13, 14, 
    13, 14, 15, // Face 4
    16, 17, 18, 
    17, 18, 19, // Face 5
    20, 21, 22, 
    21, 22, 23, // Face 6
}