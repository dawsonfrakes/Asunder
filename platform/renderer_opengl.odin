#+build !darwin

package main

import gl "../basic/opengl"
import "../game"

opengl_rect_instances: [dynamic]OpenGL_Rect_Instance
opengl_window_divisor: [2]f32 = 1.0

opengl_main_fbo: u32
opengl_main_fbo_color0: u32
opengl_main_fbo_depth: u32

opengl_rect_shader: u32
opengl_rect_vao: u32
opengl_rect_vbo: u32
opengl_rect_ebo: u32
opengl_rect_ibo: u32
opengl_rect_textures: [game.Rect_Texture]u32

OpenGL_Rect_Element :: u8
OpenGL_Rect_Vertex :: struct {
	position: [2]f32,
}
OpenGL_Rect_Instance :: struct {
	offset: [3]f32,
	scale: [2]f32,
	texcoords: [2][2]f32,
	color: [4]f32,
	rotation: f32,
	texture_index: u32,
}

opengl_rect_vertices := [?]OpenGL_Rect_Vertex{
	{position = {-0.5, -0.5}},
	{position = {+0.5, -0.5}},
	{position = {+0.5, +0.5}},
	{position = {-0.5, +0.5}},
}
opengl_rect_elements := [?]OpenGL_Rect_Element{
	0, 1, 2, 2, 3, 0,
}

opengl_init :: proc "contextless" () {
	opengl_platform_init()

	gl.CreateFramebuffers(1, &opengl_main_fbo)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_color0)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_depth)

	{
		vsrc: cstring = `#version 450

		layout(location = 0) in vec2 a_position;
		layout(location = 1) in vec3 i_offset;
		layout(location = 2) in vec2 i_scale;
		layout(location = 3) in vec4 i_texcoords;
		layout(location = 4) in vec4 i_color;
		layout(location = 5) in float i_rotation;
		layout(location = 6) in uint i_texture_index;

		layout(location = 3) out vec2 f_texcoord;
		layout(location = 4) out vec4 f_color;
		layout(location = 6) flat out uint f_texture_index;

		void main() {
			gl_Position = vec4(a_position * i_scale + i_offset.xy, i_offset.z, 1.0);
			f_texcoord = vec2(mix(i_texcoords.x, i_texcoords.z, float((gl_VertexID + 1) / 2 == 1)), mix(i_texcoords.y, i_texcoords.w, float(gl_VertexID / 2 == 1)));
			f_color = i_color;
			f_texture_index = i_texture_index;
		}
		`
		vshader := gl.CreateShader(gl.VERTEX_SHADER)
		defer gl.DeleteShader(vshader)
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
		defer gl.DeleteShader(fshader)
		gl.ShaderSource(fshader, 1, &fsrc, nil)
		gl.CompileShader(fshader)

		opengl_rect_shader = gl.CreateProgram()
		gl.AttachShader(opengl_rect_shader, vshader)
		gl.AttachShader(opengl_rect_shader, fshader)
		gl.LinkProgram(opengl_rect_shader)
		gl.DetachShader(opengl_rect_shader, fshader)
		gl.DetachShader(opengl_rect_shader, vshader)

		for i in 0..<32 {
			gl.ProgramUniform1i(opengl_rect_shader, cast(i32) i, cast(i32) i)
		}
	}

	{
		gl.CreateTextures(gl.TEXTURE_2D, 1, &opengl_rect_textures[.WHITE])
		gl.TextureStorage2D(opengl_rect_textures[.WHITE], 1, gl.RGBA8, 1, 1)
		white_pixel: u32 = 0xFFFFFFFF
		gl.TextureSubImage2D(opengl_rect_textures[.WHITE], 0, 0, 0, 1, 1, gl.RGBA, gl.UNSIGNED_BYTE, &white_pixel)

		@static
		font_bmp := #load("../assets/textures/mikado.bmp")
		pixels_offset := (cast(^u32) raw_data(font_bmp[0x0A:][:4]))^
		pixels_width := (cast(^i32) raw_data(font_bmp[0x12:][:4]))^
		pixels_height := (cast(^i32) raw_data(font_bmp[0x16:][:4]))^
		pixels_bits_per := (cast(^u16) raw_data(font_bmp[0x1C:][:2]))^
		pixels := font_bmp[pixels_offset:][:pixels_width * pixels_height * cast(i32) pixels_bits_per / 8]

		gl.CreateTextures(gl.TEXTURE_2D, 1, &opengl_rect_textures[.FONT])
		gl.TextureStorage2D(opengl_rect_textures[.FONT], 1, gl.RGBA8, cast(u32) pixels_width, cast(u32) pixels_height)
		gl.TextureSubImage2D(opengl_rect_textures[.FONT], 0, 0, 0, cast(u32) pixels_width, cast(u32) pixels_height, gl.BGRA, gl.UNSIGNED_BYTE, raw_data(pixels))
	}

	{
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
		gl.VertexArrayAttribFormat(opengl_rect_vao, position_attrib, 2, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Vertex, position))

		offset_attrib :: 1
		gl.EnableVertexArrayAttrib(opengl_rect_vao, offset_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, offset_attrib, ibo_binding)
		gl.VertexArrayAttribFormat(opengl_rect_vao, offset_attrib, 3, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Instance, offset))

		scale_attrib :: 2
		gl.EnableVertexArrayAttrib(opengl_rect_vao, scale_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, scale_attrib, ibo_binding)
		gl.VertexArrayAttribFormat(opengl_rect_vao, scale_attrib, 2, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Instance, scale))

		texcoords_attrib :: 3
		gl.EnableVertexArrayAttrib(opengl_rect_vao, texcoords_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, texcoords_attrib, ibo_binding)
		gl.VertexArrayAttribFormat(opengl_rect_vao, texcoords_attrib, 4, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Instance, texcoords))

		color_attrib :: 4
		gl.EnableVertexArrayAttrib(opengl_rect_vao, color_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, color_attrib, ibo_binding)
		gl.VertexArrayAttribFormat(opengl_rect_vao, color_attrib, 4, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Instance, color))

		rotation_attrib :: 5
		gl.EnableVertexArrayAttrib(opengl_rect_vao, rotation_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, rotation_attrib, ibo_binding)
		gl.VertexArrayAttribFormat(opengl_rect_vao, rotation_attrib, 1, gl.FLOAT, false, cast(u32) offset_of(OpenGL_Rect_Instance, rotation))

		texture_index_attrib :: 6
		gl.EnableVertexArrayAttrib(opengl_rect_vao, texture_index_attrib)
		gl.VertexArrayAttribBinding(opengl_rect_vao, texture_index_attrib, ibo_binding)
		gl.VertexArrayAttribIFormat(opengl_rect_vao, texture_index_attrib, 1, gl.UNSIGNED_INT, cast(u32) offset_of(OpenGL_Rect_Instance, texture_index))
	}
}

opengl_deinit :: proc "contextless" () {
	opengl_platform_deinit()
}

opengl_resize :: proc "contextless" () {
	if platform_width <= 0 || platform_height <= 0 do return

	opengl_window_divisor = {
		cast(f32) max(1, platform_width - 1),
		cast(f32) max(1, platform_height - 1),
	}

	fbo_color_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max)
	fbo_depth_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max)
	fbo_samples := cast(u32) min(fbo_color_samples_max, fbo_depth_samples_max)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, gl.RGBA16F, cast(u32) platform_width, cast(u32) platform_height)
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_color0)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, gl.DEPTH_COMPONENT32F, cast(u32) platform_width, cast(u32) platform_height)
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.DEPTH_ATTACHMENT, gl.RENDERBUFFER, opengl_main_fbo_depth)
}

opengl_present :: proc "contextless" () {
	if platform_width <= 0 || platform_height <= 0 do return

	gl.BindFramebuffer(gl.FRAMEBUFFER, opengl_main_fbo)

	gl.Viewport(0, 0, cast(u32) platform_width, cast(u32) platform_height)

	rect_instance_count := len(opengl_rect_instances)
	gl.NamedBufferData(opengl_rect_ibo, cast(uintptr) rect_instance_count * size_of(OpenGL_Rect_Instance), raw_data(opengl_rect_instances[:]), gl.STREAM_DRAW)
	defer clear(&opengl_rect_instances)

	gl.Enable(gl.BLEND)
	gl.BlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA)
	gl.UseProgram(opengl_rect_shader)
	for texture, index in opengl_rect_textures {
		gl.BindTextureUnit(cast(u32) index, texture)
	}
	gl.BindVertexArray(opengl_rect_vao)
	gl.DrawElementsInstancedBaseVertexBaseInstance(
		gl.TRIANGLES,
		len(opengl_rect_elements),
		gl.UNSIGNED_BYTE when OpenGL_Rect_Element == u8 else gl.UNSIGNED_INT,
		nil,
		cast(u32) rect_instance_count,
		0, 0)

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	gl.Clear(0) // note: fixes intel driver bug

	gl.Enable(gl.FRAMEBUFFER_SRGB)
	gl.BlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, platform_width, platform_height,
		0, 0, platform_width, platform_height,
		gl.COLOR_BUFFER_BIT, gl.NEAREST)
	gl.Disable(gl.FRAMEBUFFER_SRGB)
	opengl_platform_present()
}

opengl_clear :: proc(color0: [4]f32, depth: f32) {
	color0, depth := color0, depth
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.COLOR, 0, raw_data(color0[:]))
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.DEPTH, 0, &depth)
}

opengl_rect :: proc(position: [3]f32, size: [2]f32, texcoords: [2][2]f32, texture: game.Rect_Texture, color: [4]f32, rotation: f32) {
	xy := position.xy / opengl_window_divisor * 2.0 - 1.0
	append(&opengl_rect_instances, OpenGL_Rect_Instance{
		offset = {xy.x, xy.y, position.z / 2000.0 + 1.0},
		scale = size / opengl_window_divisor * 2.0,
		texcoords = texcoords,
		color = color,
		rotation = rotation,
		texture_index = cast(u32) texture,
	})
}
