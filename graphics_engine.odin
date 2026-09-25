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

package main

import    "vendor:glfw"
import gl "vendor:OpenGL"
import    "core:time"
import m  "core:math"
import    "core:fmt"
import    "core:os"
import    "base:runtime"


far :: 1000
near :: 0.01
fov :: 70

aspect : f32

window : glfw.WindowHandle

camera_location : [3]f32 = {0, 0, 8}
camera_rotation : [3]f32 = {0, 0, 0}

meshes : [500]Mesh
next_mesh_index : i32 = 0

shader_groups : [dynamic]ShaderGroup
render_object_ids : [dynamic][2]i32

keyboard : map[string]bool

ShaderProgram   :: u32


watch            : time.Stopwatch

previous_cursor_pos : [2]f64 = {0, 0}
cursor_difference : [2]f64 = {0, 0}

Mesh :: struct {
    vao: u32,
    vbo: u32,
    ebo: u32,
    index_count: int,
}

RenderObject :: struct{
    mesh_index : i32,
    vertex_shader_index : i32,
    fragment_shader_index : i32,
    location : [3]f32,
    rotation : [3]f32,
    scale : [3]f32

}

ShaderGroup :: struct{
    render_objects : [dynamic]RenderObject,
    shader : u32
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


intialize_window :: proc(size : [2]i32){

    keyboard = make(map[string]bool)

    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window = glfw.CreateWindow(size.x, size.y, "Rotating Cube", nil, nil)
    assert(window != nil)
    aspect = f32(size.x)/f32(size.y)
    
    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(1)

    // Load OpenGL 3.3 function pointers.
    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    w, h := glfw.GetFramebufferSize(window)
    gl.Viewport(0,0,w,h)

    // Key press / Window-resize behaviour
    glfw.SetKeyCallback(window, callback_key)
    glfw.SetWindowRefreshCallback(window, window_refresh)
    glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)

    


    gl.Enable(gl.DEPTH_TEST)

    // Start rotation timer.
    time.stopwatch_start(&watch)

}
terminate_window :: proc(){
    glfw.Terminate()
}

load_mesh :: proc(vertices : []f32, indices : []u32) -> i32{

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
    gl.VertexAttribPointer(0,                   // index
                           3,                   // size
                           gl.FLOAT,            // type
                           gl.FALSE,            // normalized
                           3 * size_of(f32),    // stride
                           0)                   // offset
    
    // Enable the vertex position and color attributes defined above.
    gl.EnableVertexAttribArray(0)
    mesh.index_count = len(indices)

    // Optional: unbind VAO
    gl.BindVertexArray(0)

    meshes[next_mesh_index] = mesh
    next_mesh_index += 1
    return next_mesh_index-1
}

render_mesh :: proc(mesh_index : i32, location : [3]f32, shader : u32) -> [2]i32{

    renderObject : RenderObject = {
        mesh_index = mesh_index,
        vertex_shader_index = 0,
        fragment_shader_index = 0,
        location = location,
        rotation = {0, 0, 0.0},
        scale = {0.5, 0.5, 0.5}
    }

    object_id :[2]i32

    if int(shader) < len(shader_groups){
        append(&shader_groups[shader].render_objects, renderObject)
        object_id = {i32(shader), i32(len(shader_groups[shader].render_objects))}
    }
    else{
        fmt.panicf("trying to add a render object ot shader group which doesnt exist")
    }
    return object_id
}


load_shader ::proc(vertex_str:string, fragment_str:string) -> u32{
    program_ok      : bool
    shader      : u32
    shader, program_ok = gl.load_shaders_source(vertex_str, fragment_str);
    if !program_ok {
        fmt.println("ERROR: Failed to load and compile shaders."); os.exit(1)
    }
    shaderGroup : ShaderGroup = {
        render_objects = {},
        shader = shader
    }
    append(&shader_groups, shaderGroup)

    return u32(len(shader_groups)-1)
}



render_screen :: proc() {

    cursor_pos :[2]f64 = {0, 0}
    cursor_pos.x, cursor_pos.y = glfw.GetCursorPos(window)
    cursor_difference = cursor_pos - previous_cursor_pos

    raw_duration        := time.stopwatch_duration(watch)
    secs                := f32(time.duration_seconds(raw_duration))

    f := 1.0 / m.tan_f32(m.to_radians_f32(fov) / 2.0)
    perspective_mat := [16]f32 {
        f/aspect, 0, 0,  0,
        0,        f, 0,  0,
        0,        0, (far + near)/(near - far), -1,
        0,        0, (2*far*near)/(near - far), 0,
    }

    view_mat := make_view_matrix(camera_location, camera_rotation)

    perspective_ptr : [^] f32 = &perspective_mat[0]
    view_ptr : [^] f32 = &view_mat[0]


    defer gl.BindVertexArray(0)

    // Draw commands.
    gl.ClearColor(0.0, 0.0, 0.0, 1)
    gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)


    for shader in shader_groups{
        
        gl.UseProgram(shader.shader)

        gl.UniformMatrix4fv(gl.GetUniformLocation(shader.shader, "perspective_mat"), 1, gl.FALSE, perspective_ptr)
        gl.UniformMatrix4fv(gl.GetUniformLocation(shader.shader, "view_mat"), 1, gl.FALSE, view_ptr)

        for object in shader.render_objects {

            model_mat := make_model_matrix(object.location, object.scale, object.rotation)
            model_ptr : [^] f32 = &model_mat[0]
            gl.UniformMatrix4fv(gl.GetUniformLocation(shader.shader, "model_mat"), 1, gl.FALSE, model_ptr)
            // Set model matrix for this particular cube
            gl.BindVertexArray(meshes[object.mesh_index].vao)

            gl.DrawElements(
                gl.TRIANGLES,
                i32(meshes[object.mesh_index].index_count),
                gl.UNSIGNED_INT,
                nil,
            )
        }     
    }
    glfw.SwapBuffers(window)

    previous_cursor_pos = cursor_pos
}

// Quit the window if the ESC key is pressed. This procedure is called by
// glfw.SetKeyCallback.
callback_key :: proc "c" ( window : glfw.WindowHandle, key, scancode, action, mods : i32 ) {
    if action == glfw.PRESS && key == glfw.KEY_ESCAPE {
        glfw.SetWindowShouldClose(window, true)
    }
    else if action == glfw.PRESS && key == glfw.KEY_A {
        keyboard["A"] = true
    }
    else if action == glfw.PRESS && key == glfw.KEY_D {
        keyboard["D"] = true
    }
    else if action == glfw.PRESS && key == glfw.KEY_W {
        keyboard["W"] = true
    }
    else if action == glfw.PRESS && key == glfw.KEY_S {
        keyboard["S"] = true
    }
    else if action == glfw.RELEASE && key == glfw.KEY_A {
        keyboard["A"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_D {
        keyboard["D"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_W {
        keyboard["W"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_S {
        keyboard["S"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_LEFT {
        keyboard["LEFT"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_RIGHT {
        keyboard["RIGHT"] = false
    }
    else if action == glfw.PRESS && key == glfw.KEY_LEFT {
        keyboard["LEFT"] = true
    }
    else if action == glfw.PRESS && key == glfw.KEY_RIGHT {
        keyboard["RIGHT"] = true
    }
    else if action == glfw.RELEASE && key == glfw.KEY_DOWN {
        keyboard["DOWN"] = false
    }
    else if action == glfw.RELEASE && key == glfw.KEY_UP {
        keyboard["UP"] = false
    }
    else if action == glfw.PRESS && key == glfw.KEY_DOWN {
        keyboard["DOWN"] = true
    }
    else if action == glfw.PRESS && key == glfw.KEY_UP {
        keyboard["UP"] = true
    }


}

// If the window needs to be redrawn (e.g. the user resizes the window), redraw the window.
// This procedure is called by  glfw.SetWindowRefreshCallback.
window_refresh :: proc "c" ( window : glfw.WindowHandle ) {
    context = runtime.default_context()
    w, h : i32
    w, h = glfw.GetWindowSize(window)
    gl.Viewport(0,0,w,h)
    aspect = f32(w)/f32(h)
}
