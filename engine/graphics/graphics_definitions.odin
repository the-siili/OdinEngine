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


TEXTURE_WRAP_MODE_REPEAT :: gl.REPEAT
TEXTURE_WRAP_MODE_CLAMP_TO_EDGE :: gl.CLAMP_TO_EDGE

TEXTURE_FILTER_LINEAR :: gl.LINEAR
TEXTURE_FILTER_NEAREST :: gl.NEAREST