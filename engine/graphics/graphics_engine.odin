// An elementary program in Odin which creates a colored cube
// which rotates over time.
//
// Created by Benjamin Thompson. Available at:
// https://github.com/bg-thompson/OpenGL-Tutorials-In-Odin
// Last updated: 2024.09.15
//
// To compile and run the program with optimizations, use the command
//
//     odin run Rotating-Cube -o:speed
//
// Created for educational purposes. Used verbatim, it is probably
// unsuitable for production code.

package graphics

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:time"
import m  "core:math"
import    "core:fmt"
import    "core:os"
import    "base:runtime"
import    "core:image"
import  png "core:image/png"
import      "core:strconv"
import      "core:strings"
import d "../definition"


far :: 1000
near :: 0.01
fov :: 70

aspect : f32

camera_location : [3]f32 = {0, 0, 8}
camera_rotation : [3]f32 = {0, 0, 0}

meshes : map[d.MeshId]Mesh
next_mesh_index : d.MeshId = 0

shaders : map[d.ShaderId]u32
next_shader_index : d.ShaderId = 0

render_objects : map[d.RenderObjectId]^RenderObject
next_render_object_index : d.RenderObjectId = 0

textures : map[d.TextureId]u32
next_texture_index : d.TextureId = 0

perspective_mat : [16]f32


Mesh :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    index_count: int,
}

RenderObject :: struct{
    mesh_index : i32,
    location : [3]f32,
    rotation : [3]f32,
    scale : [3]f32,
    material : ^Material
}

Material :: struct{
    shader: i32,
    textures:map[string]i32,
    floats:map[string]f32,
    vec2s:map[string][2]f32,
    vec3s:map[string][3]f32
}

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

    rotation_mat := mat4_mul(rotation_z, rotation_y)
    rotation_mat = mat4_mul(rotation_mat , rotation_x)

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

mat4_mul :: proc(a, b: [16]f32) -> [16]f32 {
    result: [16]f32

    for col := 0; col < 4; col += 1 {
        for row := 0; row < 4; row += 1 {
            result[col * 4 + row] =
                a[0 * 4 + row] * b[col * 4 + 0] +
                a[1 * 4 + row] * b[col * 4 + 1] +
                a[2 * 4 + row] * b[col * 4 + 2] +
                a[3 * 4 + row] * b[col * 4 + 3]
        }
    }

    return result
}

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



load_mesh :: proc(vertices : []f32, indices : []u32) -> d.MeshId{

    mesh : Mesh

    // Set up vertex array / element array / buffer objects
    gl.GenVertexArrays(1, &mesh.vao)
    gl.BindVertexArray(mesh.vao)

    gl.GenBuffers(1, &mesh.vbo)
    gl.BindBuffer(gl.ARRAY_BUFFER, mesh.vbo)

    gl.GenBuffers(1, &mesh.ebo)
    gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, mesh.ebo)


    // Describe GPU buffer.
    gl.BufferData(gl.ARRAY_BUFFER,     // target
                  len(vertices) * size_of(f32),   // size of the buffer object's data store
                  raw_data(vertices),           // data used for initialization
                  gl.STATIC_DRAW)      // usage

    gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, 
                    len(indices)*size_of(u32), 
                    raw_data(indices), 
                    gl.STATIC_DRAW)

    // Position and color attributes. Don't forget to enable!
    //vertices coords
    gl.VertexAttribPointer(0,                   // index
                           3,                   // size
                           gl.FLOAT,            // type
                           gl.FALSE,            // normalized
                           8 * size_of(f32),    // stride
                           0)                   // offset
    //uv
    gl.VertexAttribPointer(1,                   // index
                        2,                   // size
                        gl.FLOAT,            // type
                        gl.FALSE,            // normalized
                        8 * size_of(f32),    // stride
                        3 * size_of(f32))
    //normals
    gl.VertexAttribPointer(2,                   // index
                        3,                   // size
                        gl.FLOAT,            // type
                        gl.FALSE,            // normalized
                        8 * size_of(f32),    
                        5 * size_of(f32))                     // offset
    // Enable the vertex position and color attributes defined above.
    gl.EnableVertexAttribArray(0)
    gl.EnableVertexAttribArray(1)
    gl.EnableVertexAttribArray(2)
    mesh.index_count = len(indices)

    // Optional: unbind VAO
    gl.BindVertexArray(0)

    meshes[next_mesh_index] = mesh
    defer next_mesh_index += 1
    return next_mesh_index
}

render_mesh :: proc(mesh_index : i32, location : [3]f32, material : ^Material) -> d.RenderObjectId{

    renderObject := new(RenderObject)
    renderObject.mesh_index = mesh_index
    renderObject.location = location
    renderObject.rotation = {0, 0, 0.0}
    renderObject.scale = {0.5, 0.5, 0.5}
    renderObject.material = material

    render_objects[next_render_object_index] = renderObject
    defer next_render_object_index += 1
    return next_render_object_index
}

load_shader ::proc(vertex_str:string, fragment_str:string) -> d.ShaderId{
    program_ok      : bool
    shader      : u32
    shader, program_ok = gl.load_shaders_source(vertex_str, fragment_str);
    if !program_ok {
        fmt.println("ERROR: Failed to load and compile shaders."); os.exit(1)
    }

    shaders[next_shader_index] = shader
    defer next_shader_index += 1
    return next_shader_index
}

load_texture ::proc(texture_bytes : []u8) -> d.TextureId{

    image_ptr           :  ^image.Image
    err                 :  image.Error
    options             := image.Options{.alpha_add_if_missing}

    image_ptr, err =  png.load_from_bytes(texture_bytes, options)
    if err != nil{
        fmt.printfln("ERROR")
    }
    defer png.destroy(image_ptr)
    
    texture_pixel_array := make([]u8, len(image_ptr.pixels.buf))

    for b, i in image_ptr.pixels.buf {
        texture_pixel_array[i] = b
    }
    

    image_w := i32(image_ptr.width)
    image_h := i32(image_ptr.height)
    
    texture : u32
    gl.GenTextures(1, &texture)
    gl.BindTexture(gl.TEXTURE_2D, texture)
    
    gl.TexImage2D(
        gl.TEXTURE_2D,    // texture type
        0,                // level of detail number (default = 0)
        gl.RGBA,          // texture format
        image_w,          // width
        image_h,          // height
        0,                // border, must be 0
        gl.RGBA,          // pixel data format
        gl.UNSIGNED_BYTE, // data type of pixel data
        &texture_pixel_array[0],  // image data
    )
    gl.GenerateMipmap(gl.TEXTURE_2D)

    // Texture wrapping options.
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
    
    // Texture filtering options.
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
    
    textures[next_texture_index] = texture
    defer next_texture_index += 1
    return next_texture_index

}

update_perspective_matrix ::proc(window : glfw.WindowHandle){
    size_x, size_y := glfw.GetWindowSize(window)
    aspect = f32(size_x)/f32(size_y)
    f := 1.0 / m.tan_f32(m.to_radians_f32(fov) / 2.0)
    perspective_mat = [16]f32 {
        f/aspect, 0, 0,  0,
        0,        f, 0,  0,
        0,        0, (far + near)/(near - far), -1,
        0,        0, (2*far*near)/(near - far), 0,
    }
}

render_screen :: proc(window : glfw.WindowHandle) {


    view_mat := make_view_matrix(camera_location, camera_rotation)

    perspective_ptr : [^] f32 = &perspective_mat[0]
    view_ptr : [^] f32 = &view_mat[0]



    // Draw commands.
    gl.ClearColor(0.0, 0.0, 0.0, 1)
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

    for object_key in render_objects {

        object := render_objects[object_key]
        shader := shaders[object.material.shader]
        gl.UseProgram(shader )

        gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "perspective_mat"), 1, gl.FALSE, perspective_ptr)
        gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "view_mat"), 1, gl.FALSE, view_ptr)
        

        model_mat := make_model_matrix(object.location, object.scale, object.rotation)
        model_ptr : [^] f32 = &model_mat[0]
        gl.UniformMatrix4fv(gl.GetUniformLocation(shader, "model_mat"), 1, gl.FALSE, model_ptr)
    
        bind_material_uniforms(shader, object.material)


        // Set model matrix for this particular cube
        gl.BindVertexArray(meshes[object.mesh_index].vao)
        gl.DrawElements(
            gl.TRIANGLES,
            i32(meshes[object.mesh_index].index_count),
            gl.UNSIGNED_INT,
            nil,
        )
    }     
    
    glfw.SwapBuffers(window)

    
}

bind_material_uniforms :: proc(shader : u32, material : ^Material){
        if len(material.textures) > 0 {
            tex_count := 0
            for texture_key in material.textures{
                texture_loc := gl.GetUniformLocation(shader, strings.clone_to_cstring(texture_key))
                gl.Uniform1i(texture_loc, i32(tex_count))
                gl.ActiveTexture(gl.TEXTURE0 + u32(tex_count)); 
                gl.BindTexture(gl.TEXTURE_2D, textures[material.textures[texture_key]]);
                tex_count += 1
            }
        }
        if len(material.floats) > 0{
            count := 0
            for key in material.floats{
                loc := gl.GetUniformLocation(shader, strings.clone_to_cstring(key))
                gl.Uniform1f(loc, material.floats[key])
                count += 1
            }
        }
        if len(material.vec2s) > 0{
            count := 0
            for key in material.vec2s{
                loc := gl.GetUniformLocation(shader, strings.clone_to_cstring(key))
                gl.Uniform2f(loc, material.vec2s[key].x, material.vec2s[key].y)
                count += 1
            }
        }
        if len(material.vec3s) > 0{
            count := 0
            for key in material.vec3s{
                loc := gl.GetUniformLocation(shader, strings.clone_to_cstring(key))
                gl.Uniform3f(loc, material.vec3s[key].x, material.vec3s[key].y, material.vec3s[key].z)
                count += 1
            }
        }
}
