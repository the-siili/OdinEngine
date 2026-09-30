package window

import    "vendor:glfw"
import gl "vendor:OpenGL"
import ge "../graphics"
import    "base:runtime"
import de "../debugger"

window : glfw.WindowHandle

keyboard : map[string]bool

cursor_pos :[2]f64 = {0, 0}
previous_cursor_pos : [2]f64 = {0, 0}
cursor_difference : [2]f64 = {0, 0}



initialize_window :: proc(size : [2]i32) -> glfw.WindowHandle{

    keyboard = make(map[string]bool)

    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window = glfw.CreateWindow(size.x, size.y, "Rotating Cube", nil, nil)
    assert(window != nil)

    glfw.MakeContextCurrent(window)
    glfw.SwapInterval(0)

    // Load OpenGL 3.3 function pointers.
    gl.load_up_to(3,3, glfw.gl_set_proc_address)

    w, h := glfw.GetFramebufferSize(window)
    gl.Viewport(0,0,w,h)

    // Key press / Window-resize behaviour
    glfw.SetKeyCallback(window, callback_key)
    glfw.SetWindowRefreshCallback(window, window_refresh)
    glfw.SetInputMode(window, glfw.CURSOR, glfw.CURSOR_DISABLED)

    


    gl.Enable(gl.DEPTH_TEST)

    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    ge.update_perspective_matrix(window)
    return window
}
terminate_window :: proc(){
    delete_map(keyboard)
    glfw.Terminate()
}

read_input :: proc(){
    de.prof_frame_part()
    glfw.PollEvents()
    update_mouse_position()
}
clear_input :: proc(){
    reset_mouse_position()
}

update_mouse_position :: proc(){
    cursor_pos.x, cursor_pos.y = glfw.GetCursorPos(window)
    cursor_difference = cursor_pos - previous_cursor_pos
}
reset_mouse_position :: proc(){
    previous_cursor_pos = cursor_pos
}

get_input_vec3 ::proc(x:string, xn:string,  y:string, yn:string, z:string, zn:string) -> [3]f32{
    vec : [3]f32 = {0, 0, 0}
    if keyboard[z]{
        vec.z = 1
        //trans.addPosition(entity, forward*player_data.speed*f32(delta_time))
    }
    
    if keyboard[zn]{
        vec.z = -1
        //trans.addPosition(entity, -forward*player_data.speed*f32(delta_time))
    }
    
    if keyboard[xn]{
        vec.x = -1
        //trans.addPosition(entity, -right*player_data.speed*f32(delta_time))
    }
    if keyboard[x]{
        vec.x = 1
        //trans.addPosition(entity, right*player_data.speed*f32(delta_time))
    }
    if keyboard[y]{
        vec.y = 1
        //trans.addPosition(entity, {0, 1, 0}*player_data.speed*f32(delta_time))
    }
    if keyboard[yn]{
        vec.y = -1
        //trans.addPosition(entity, -{0, 1, 0}*player_data.speed*f32(delta_time))
    }
    return vec
}

get_input_vec2 ::proc(x:string, xn:string,  y:string, yn:string) -> [2]f32{
    vec : [2]f32 = {0, 0}
    if keyboard[xn]{
        vec.x = -1
        //trans.addPosition(entity, -right*player_data.speed*f32(delta_time))
    }
    if keyboard[x]{
        vec.x = 1
        //trans.addPosition(entity, right*player_data.speed*f32(delta_time))
    }
    if keyboard[y]{
        vec.y = 1
        //trans.addPosition(entity, {0, 1, 0}*player_data.speed*f32(delta_time))
    }
    if keyboard[yn]{
        vec.y = -1
        //trans.addPosition(entity, -{0, 1, 0}*player_data.speed*f32(delta_time))
    }
    return vec
}


// Quit the window if the ESC key is pressed. This procedure is called by
// glfw.SetKeyCallback.
callback_key :: proc "c" ( window : glfw.WindowHandle, key, scancode, action, mods : i32 ) {
    if action == glfw.PRESS && key == glfw.KEY_ESCAPE {
        glfw.SetWindowShouldClose(window, true)
    }
    else if action == glfw.PRESS {
        switch key{
            case glfw.KEY_A:
                keyboard["A"] = true
            case glfw.KEY_D:
                keyboard["D"] = true
            case glfw.KEY_W:
                keyboard["W"] = true
            case glfw.KEY_S:
                keyboard["S"] = true
            case glfw.KEY_UP:
                keyboard["UP"] = true
            case glfw.KEY_DOWN:
                keyboard["DOWN"] = true
            case glfw.KEY_LEFT:
                keyboard["LEFT"] = true
            case glfw.KEY_RIGHT:
                keyboard["RIGHT"] = true
            case glfw.KEY_SPACE:
                keyboard["SPACE"] = true
            case glfw.KEY_LEFT_SHIFT:
                keyboard["L_SHIFT"] = true

        } 
    }
    else if action == glfw.RELEASE {
        switch key{
            case glfw.KEY_A:
                keyboard["A"] = false
            case glfw.KEY_D:
                keyboard["D"] = false
            case glfw.KEY_W:
                keyboard["W"] = false
            case glfw.KEY_S:
                keyboard["S"] = false
            case glfw.KEY_UP:
                keyboard["UP"] = false
            case glfw.KEY_DOWN:
                keyboard["DOWN"] = false
            case glfw.KEY_LEFT:
                keyboard["LEFT"] = false
            case glfw.KEY_RIGHT:
                keyboard["RIGHT"] = false
            case glfw.KEY_SPACE:
                keyboard["SPACE"] = false
            case glfw.KEY_LEFT_SHIFT:
                keyboard["L_SHIFT"] = false

        } 
    }


}

// If the window needs to be redrawn (e.g. the user resizes the window), redraw the window.
// This procedure is called by  glfw.SetWindowRefreshCallback.
window_refresh :: proc "c" ( window : glfw.WindowHandle ) {
    context = runtime.default_context()
    w, h : i32
    w, h = glfw.GetWindowSize(window)
    gl.Viewport(0,0,w,h)
    ge.update_perspective_matrix(window)
}
