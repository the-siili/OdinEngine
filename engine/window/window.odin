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

package window

import    "vendor:glfw"
import gl "vendor:OpenGL"
import ge "../graphics"
import    "base:runtime"


window : glfw.WindowHandle

keyboard : map[string]bool

cursor_pos :[2]f64 = {0, 0}
previous_cursor_pos : [2]f64 = {0, 0}
cursor_difference : [2]f64 = {0, 0}



intialize_window :: proc(size : [2]i32) -> glfw.WindowHandle{

    keyboard = make(map[string]bool)

    glfw.Init()

    glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)

    window = glfw.CreateWindow(size.x, size.y, "Rotating Cube", nil, nil)
    assert(window != nil)

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

    gl.Enable(gl.BLEND)
    gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
    ge.update_perspective_matrix(window)
    return window
}
terminate_window :: proc(){
    glfw.Terminate()
}

update_mouse_position :: proc(){
    cursor_pos.x, cursor_pos.y = glfw.GetCursorPos(window)
    cursor_difference = cursor_pos - previous_cursor_pos
}
reset_mouse_position :: proc(){
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
    ge.update_perspective_matrix(window)
}
