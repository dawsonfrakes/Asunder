#+build windows, linux, freebsd, openbsd, netbsd, haiku
package main

import gl "vendor:OpenGL"
import "../game"

OpenGL_Rect_Element :: u8
OpenGL_Rect_Vertex :: struct {
	position: [2]f32,
}
OpenGL_Rect_Instance :: struct {
	offset: [3]f32,
	scale: [2]f32,
	color: [4]f32,
	texcoords: [2][2]f32,
	rotation: f32,
	texture_index: u32,
}

opengl_main_fbo: u32
opengl_main_fbo_color0: u32
opengl_main_fbo_depth: u32

opengl_rect_shader: u32
opengl_rect_vao: u32
opengl_rect_vbo: u32
opengl_rect_ebo: u32
opengl_rect_ibo: u32
opengl_rect_elements := []OpenGL_Rect_Element{0, 1, 2, 2, 3, 0}
opengl_rect_vertices := []OpenGL_Rect_Vertex{
	{position = {-0.5, -0.5}},
	{position = {+0.5, -0.5}},
	{position = {+0.5, +0.5}},
	{position = {-0.5, +0.5}},
}
opengl_rect_instances: [dynamic]OpenGL_Rect_Instance

opengl_init :: proc() {
	opengl_platform_init()

	gl.ClipControl(gl.LOWER_LEFT, gl.ZERO_TO_ONE)

	gl.CreateFramebuffers(1, &opengl_main_fbo)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_color0)
	gl.CreateRenderbuffers(1, &opengl_main_fbo_depth)

	gl.CreateBuffers(1, &opengl_rect_vbo)
	gl.NamedBufferData(opengl_rect_vbo, len(opengl_rect_vertices) * size_of(OpenGL_Rect_Vertex), raw_data(opengl_rect_vertices), gl.STATIC_DRAW)
	gl.CreateBuffers(1, &opengl_rect_ebo)
	gl.NamedBufferData(opengl_rect_ebo, len(opengl_rect_elements) * size_of(OpenGL_Rect_Element), raw_data(opengl_rect_elements), gl.STATIC_DRAW)
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
	gl.VertexArrayAttribFormat(opengl_rect_vao, offset_attrib, 3, gl.FLOAT, false, u32(offset_of(OpenGL_Rect_Instance, offset)))
}

opengl_deinit :: proc() {
	opengl_platform_deinit()
}

opengl_resize :: proc() {
	if platform_size.x <= 0 || platform_size.y <= 0 do return

	fbo_color_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max)
	fbo_depth_samples_max: i32 = ---
	gl.GetIntegerv(gl.MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max)
	fbo_samples := min(fbo_color_samples_max, fbo_depth_samples_max)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, gl.RGBA16F, i32(platform_size.x), i32(platform_size.y))
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_color0)

	gl.NamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, gl.RGBA16F, i32(platform_size.x), i32(platform_size.y))
	gl.NamedFramebufferRenderbuffer(opengl_main_fbo, gl.COLOR_ATTACHMENT0, gl.RENDERBUFFER, opengl_main_fbo_depth)
}

opengl_present :: proc() {
	if platform_size.x <= 0 || platform_size.y <= 0 do return

	gl.BindFramebuffer(gl.FRAMEBUFFER, opengl_main_fbo)

	append(&opengl_rect_instances, OpenGL_Rect_Instance{
		offset = {0.0, 0.0, 0.0},
	})

	defer clear(&opengl_rect_instances)
	if len(opengl_rect_instances) > 0 {
		// gl.UseProgram(opengl_rect_shader)
		gl.BindVertexArray(opengl_rect_vao)
		gl.NamedBufferData(opengl_rect_ibo, len(opengl_rect_instances) * size_of(OpenGL_Rect_Element), raw_data(opengl_rect_instances), gl.STATIC_DRAW)
		gl.DrawElementsInstancedBaseVertexBaseInstance(
			gl.TRIANGLES,
			i32(len(opengl_rect_elements)),
			gl.UNSIGNED_BYTE,
			rawptr(uintptr(0)),
			i32(len(opengl_rect_instances)),
			0, 0)
	}

	gl.BindFramebuffer(gl.FRAMEBUFFER, 0)

	gl.Clear(0) // NOTE(dfra): fixes intel driver bug

	gl.Enable(gl.FRAMEBUFFER_SRGB)
	gl.BlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, i32(platform_size.x), i32(platform_size.y),
		0, 0, i32(platform_size.x), i32(platform_size.y),
		gl.COLOR_BUFFER_BIT, gl.NEAREST)
	gl.Disable(gl.FRAMEBUFFER_SRGB)

	opengl_platform_present()
}

opengl_clear :: proc(color: [4]f32, depth: f32) {
	color, depth := color, depth
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.COLOR, 0, raw_data(color[:]))
	gl.ClearNamedFramebufferfv(opengl_main_fbo, gl.DEPTH, 0, &depth)
}

opengl_rect :: proc(position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32, texture: game.Rect_Texture, rotation: f32, z_index: f32) {

}
