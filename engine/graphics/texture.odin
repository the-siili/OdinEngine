package graphics



import gl "vendor:OpenGL"
import    "core:fmt"
import    "core:image"
import  png "core:image/png"
import d "../definition"

@private
textures : map[d.TextureId]u32
@private
next_texture_index : d.TextureId = 0


load_texture ::proc(texture_bytes : []u8, 
    h_wrap_mode : i32 = TEXTURE_WRAP_MODE_CLAMP_TO_EDGE, 
    v_wrap_mode : i32 = TEXTURE_WRAP_MODE_CLAMP_TO_EDGE,
    min_filter :i32 = TEXTURE_FILTER_NEAREST,
    mag_filter :i32 = TEXTURE_FILTER_NEAREST) -> d.TextureId{

    image_ptr           :  ^image.Image
    err                 :  image.Error
    options             := image.Options{.alpha_add_if_missing}

    image_ptr, err =  png.load_from_bytes(texture_bytes, options)
    if err != nil{
        fmt.printfln("ERROR")
    }
    defer png.destroy(image_ptr)
    
    texture_pixel_array := make([]u8, len(image_ptr.pixels.buf))
    defer delete_slice(texture_pixel_array)
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
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, h_wrap_mode)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, v_wrap_mode)
    
    // Texture filtering options.
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, min_filter)
    gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, mag_filter)
    
    textures[next_texture_index] = texture
    defer next_texture_index += 1
    return next_texture_index

}

unload_texture ::proc(texture_id:d.TextureId){
    texture := textures[texture_id]
    gl.DeleteTextures(1, &texture)
    delete_key(&textures, texture_id)
}