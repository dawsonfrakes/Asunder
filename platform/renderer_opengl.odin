#+build windows, linux, freebsd, openbsd, netbsd, haiku

package main

import "base:runtime"
import "../game"
import gl "../basic/opengl"

opengl_window_divisor: [2]f32

opengl_main_fbo: u32
opengl_main_fbo_color0: u32
opengl_main_fbo_depth: u32

opengl_textures: [game.Rect_Texture]u32

OpenGL_Rect_Element :: u8
OpenGL_Rect_Vertex :: struct {
  position: [2]f32,
}
OpenGL_Rect_Instance :: struct {
  offset: [2]f32,
  scale: [2]f32,
  texcoords: [2][2]f32,
  color: [4]f32,
  rotation: f32,
  texture_index: u32,
}

opengl_rect_shader: u32
opengl_rect_vao: u32
opengl_rect_vbo: u32
opengl_rect_ebo: u32
opengl_rect_ibo: u32
opengl_rect_elements := [?]OpenGL_Rect_Element{0, 1, 2, 2, 3, 0}
opengl_rect_vertices := [?]OpenGL_Rect_Vertex{
  {position = {-0.5, -0.5}},
  {position = {+0.5, -0.5}},
  {position = {+0.5, +0.5}},
  {position = {-0.5, +0.5}},
}
opengl_rect_instances: [dynamic]OpenGL_Rect_Instance

opengl_init :: proc "contextless" () {
  opengl_platform_init()

  gl.ClipControl(gl.LOWER_LEFT, gl.ZERO_TO_ONE)

  gl.CreateFramebuffers(1, &opengl_main_fbo)
  gl.CreateRenderbuffers(1, &opengl_main_fbo_color0)
  gl.CreateRenderbuffers(1, &opengl_main_fbo_depth)

  white_texture: {
    gl.CreateTextures(gl.TEXTURE_2D, 1, &opengl_textures[.WHITE])
    gl.TextureStorage2D(opengl_textures[.WHITE], 1, gl.RGBA8, 1, 1)
    white_pixel: u32 = 0xFFFFFFFF
    gl.TextureSubImage2D(opengl_textures[.WHITE], 0, 0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, &white_pixel)
  }

  remaining_textures: {
    @static mapping := [game.Rect_Texture]cstring{
      .WHITE = "", // this is special cased at :white_texture
      .FONT = "assets/textures/font.bmp",
    }
    context = runtime.default_context()
    for kind in game.Rect_Texture(1)..=max(game.Rect_Texture) {
      bmp_file := read_entire_file(mapping[kind]) or_continue
      bmp_pixels_offset := (^u32)(raw_data(bmp_file[0x0A:][:4]))^

      bmp_width := (^u32)(raw_data(bmp_file[0x12:][:4]))^
      bmp_height := (^u32)(raw_data(bmp_file[0x16:][:4]))^
      bmp_pixels := ([^]u32)(raw_data(bmp_file[bmp_pixels_offset:]))

      gl.CreateTextures(gl.TEXTURE_2D, 1, &opengl_textures[kind])
      gl.TextureStorage2D(opengl_textures[kind], 1, gl.RGBA8, bmp_width, bmp_height)
      gl.TextureSubImage2D(opengl_textures[kind], 0, 0, 0, bmp_width, bmp_height, gl.RGBA, gl.UNSIGNED_BYTE, bmp_pixels)
    }
  }

  rect_buffers: {
    gl.CreateBuffers(1, &opengl_rect_vbo)
    gl.NamedBufferData(opengl_rect_vbo, len(opengl_rect_vertices) * size_of(OpenGL_Rect_Vertex), raw_data(opengl_rect_vertices[:]), gl.STATIC_DRAW)
    gl.CreateBuffers(1, &opengl_rect_ebo)
    gl.NamedBufferData(opengl_rect_ebo, len(opengl_rect_elements) * size_of(OpenGL_Rect_Element), raw_data(opengl_rect_elements[:]), gl.STATIC_DRAW)
    gl.CreateBuffers(1, &opengl_rect_ibo)

    vbo_binding :: 0
    ibo_binding :: 1
    gl.CreateVertexArrays(1, &opengl_rect_vao)
    gl.VertexArrayElementBuffer(opengl_rect_vao, opengl_rect_ebo)
    gl.VertexArrayVertexBuffer(opengl_rect_vao, vbo_binding, opengl_rect_vbo, 0, size_of(OpenGL_Rect_Vertex))
    gl.VertexArrayVertexBuffer(opengl_rect_vao, ibo_binding, opengl_rect_ibo, 0, size_of(OpenGL_Rect_Instance))
    gl.VertexArrayBindingDivisor(opengl_rect_vao, ibo_binding, 1)

    position_attrib :: 0
    gl.EnableVertexArrayAttrib(opengl_rect_vao, position_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, position_attrib, vbo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, position_attrib, 2, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Vertex, position)))

    offset_attrib :: 1
    gl.EnableVertexArrayAttrib(opengl_rect_vao, offset_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, offset_attrib, ibo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, offset_attrib, 2, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, offset)))

    scale_attrib :: 2
    gl.EnableVertexArrayAttrib(opengl_rect_vao, scale_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, scale_attrib, ibo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, scale_attrib, 2, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, scale)))

    texcoords_attrib :: 3
    gl.EnableVertexArrayAttrib(opengl_rect_vao, texcoords_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, texcoords_attrib, ibo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, texcoords_attrib, 4, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, texcoords)))

    color_attrib :: 4
    gl.EnableVertexArrayAttrib(opengl_rect_vao, color_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, color_attrib, ibo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, color_attrib, 4, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, color)))

    rotation_attrib :: 5
    gl.EnableVertexArrayAttrib(opengl_rect_vao, rotation_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, rotation_attrib, ibo_binding)
    gl.VertexArrayAttribFormat(opengl_rect_vao, rotation_attrib, 1, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, rotation)))

    texture_index_attrib :: 6
    gl.EnableVertexArrayAttrib(opengl_rect_vao, texture_index_attrib)
    gl.VertexArrayAttribBinding(opengl_rect_vao, texture_index_attrib, ibo_binding)
    gl.VertexArrayAttribIFormat(opengl_rect_vao, texture_index_attrib, 1, gl.UNSIGNED_INT, u32(offset_of(OpenGL_Rect_Instance, texture_index)))
  }

  rect_shader: {
    vsrc: cstring = `#version 450

    layout(location = 0) in vec2 a_position;
    layout(location = 1) in vec2 i_offset;
    layout(location = 2) in vec2 i_scale;
    layout(location = 3) in vec4 i_texcoords;
    layout(location = 4) in vec4 i_color;
    layout(location = 5) in float i_rotation;
    layout(location = 6) in uint i_texture_index;

    layout(location = 3) out vec2 f_texcoord;
    layout(location = 4) out vec4 f_color;
    layout(location = 6) flat out uint f_texture_index;

    void main() {
      float turns_to_radians = i_rotation * radians(360.0);
      float c = cos(turns_to_radians);
      float s = sin(turns_to_radians);

      float x = a_position.x * c - a_position.y * s;
      float y = a_position.x * s + a_position.y * c;
      gl_Position = vec4(vec2(x, y) * i_scale + i_offset, 0.0, 1.0);
      f_texcoord = vec2(mix(i_texcoords.x, i_texcoords.z, float((gl_VertexID + 1) / 2 == 1)), mix(i_texcoords.y, i_texcoords.w, float(gl_VertexID / 2 == 1)));
      f_color = i_color;
      f_texture_index = i_texture_index;
    }
    `
    vshader := gl.CreateShader(gl.VERTEX_SHADER)
    gl.ShaderSource(vshader, 1, &vsrc, nil)
    gl.CompileShader(vshader)

    fsrc: cstring = `#version 450

    layout(location = 3) in vec2 f_texcoord;
    layout(location = 4) in vec4 f_color;
    layout(location = 6) flat in uint f_texture_index;

    layout(location = 0) out vec4 color;

    layout(location = 0) uniform sampler2D u_textures[32];

    void main() {
      color = texture(u_textures[f_texture_index], f_texcoord) * f_color;
    }
    `
    fshader := gl.CreateShader(gl.FRAGMENT_SHADER)
    gl.ShaderSource(fshader, 1, &fsrc, nil)
    gl.CompileShader(fshader)

    opengl_rect_shader = gl.CreateProgram()
    gl.AttachShader(opengl_rect_shader, vshader)
    gl.AttachShader(opengl_rect_shader, fshader)
    gl.LinkProgram(opengl_rect_shader)
    gl.DetachShader(opengl_rect_shader, fshader)
    gl.DetachShader(opengl_rect_shader, vshader)

    for i in 0..<32 do gl.ProgramUniform1i(opengl_rect_shader, i32(i), i32(i))
  }
}

opengl_deinit :: proc "contextless" () {
  opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {
  if platform_width <= 0 || platform_height <= 0 do return

  opengl_window_divisor = {
    f32(max(1, platform_width - 1)),
    f32(max(1, platform_height - 1)),
  }

  w := u32(platform_width)
  h := u32(platform_height)

  fbo_color_samples_max: i32 = ---
  gl.GetIntegerv(gl.MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max)
  fbo_depth_samples_max: i32 = ---
  gl.GetIntegerv(gl.MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max)
  fbo_samples := u32(min(fbo_color_samples_max, fbo_depth_samples_max))

  gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, gl.RGBA16F, w, h)
  gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_color0)

  gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, gl.DEPTH_COMPONENT32F, w, h)
  gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, opengl_main_fbo_depth)
}

opengl_present :: proc "contextless" () {
  if platform_width <= 0 || platform_height <= 0 do return

  w := u32(platform_width)
  h := u32(platform_height)

  gl.Viewport(0, 0, w, h)

  gl.BindFramebuffer(gl.FRAMEBUFFER, opengl_main_fbo)

  gl.NamedBufferData(opengl_rect_ibo, len(opengl_rect_instances) * size_of(OpenGL_Rect_Instance), raw_data(opengl_rect_instances[:]), gl.STATIC_DRAW)
  defer clear(&opengl_rect_instances)

  gl.Enable(gl.BLEND)
  gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
  for texture, kind in opengl_textures do gl.BindTextureUnit(u32(kind), texture)
  gl.UseProgram(opengl_rect_shader)
  gl.BindVertexArray(opengl_rect_vao)
  gl.DrawElementsInstancedBaseVertexBaseInstance(
    gl.TRIANGLES,
    len(opengl_rect_elements),
    gl.UNSIGNED_BYTE,
    cast(rawptr) cast(uintptr) 0,
    u32(len(opengl_rect_instances)),
    0, 0)
  gl.Disable(gl.BLEND)

  gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

  gl.Clear(0) // note: fixes intel driver bug

  gl.Enable(gl.FRAMEBUFFER_SRGB)
  gl.BlitNamedFramebuffer(opengl_main_fbo, 0,
    0, 0, i32(w), i32(h),
    0, 0, i32(w), i32(h),
    gl.COLOR_BUFFER_BIT, gl.NEAREST)
  gl.Disable(gl.FRAMEBUFFER_SRGB)

  opengl_platform_present()
}

opengl_clear :: proc(color0: [4]f32, depth: f32) {
  color0, depth := color0, depth
  gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.COLOR, 0, raw_data(color0[:]))
  gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.DEPTH, 0, &depth)
}

opengl_rect :: proc(position: [2]f32, size: [2]f32, color: [4]f32, texcoords: [2][2]f32, rotation: f32, texture: game.Rect_Texture) {
  append(&opengl_rect_instances, OpenGL_Rect_Instance{
    offset = position / opengl_window_divisor * 2.0 - 1.0,
    scale = size / opengl_window_divisor * 2.0,
    texcoords = texcoords,
    color = color,
    rotation = rotation,
    texture_index = u32(texture),
  })
}
