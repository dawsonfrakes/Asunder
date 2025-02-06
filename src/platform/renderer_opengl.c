#include "../modules/opengl.h"

#if TARGET_OS_WINDOWS
#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001

HGLRC opengl_ctx;
#define X(RET, NAME, ...) RET (WINAPI *NAME)(__VA_ARGS__);
GL10_FUNCTIONS
GL20_FUNCTIONS
GL30_FUNCTIONS
GL42_FUNCTIONS
GL45_FUNCTIONS
#undef X

void opengl_platform_init(void) {
	PIXELFORMATDESCRIPTOR pfd = {0};
	pfd.nSize = size_of(PIXELFORMATDESCRIPTOR);
	pfd.nVersion = 1;
	pfd.dwFlags = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER | PFD_DEPTH_DONTCARE;
	pfd.cColorBits = 24;
	s32 format = ChoosePixelFormat(platform_hdc, &pfd);
	SetPixelFormat(platform_hdc, format, &pfd);

	HGLRC temp_ctx = wglCreateContext(platform_hdc);
	wglMakeCurrent(platform_hdc, temp_ctx);

	HGLRC (WINAPI *wglCreateContextAttribsARB)(HDC, HGLRC, s32*) =
		cast(HGLRC (WINAPI *)(HDC, HGLRC, s32*))
		wglGetProcAddress("wglCreateContextAttribsARB");

	s32 attribs[] = {
		WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		WGL_CONTEXT_MINOR_VERSION_ARB, 5,
		WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		0,
	};
	opengl_ctx = wglCreateContextAttribsARB(platform_hdc, null, attribs);
	wglMakeCurrent(platform_hdc, opengl_ctx);

	wglDeleteContext(temp_ctx);

	HMODULE opengl32 = LoadLibraryW(L"opengl32");
	#define X(RET, NAME, ...) NAME = cast(RET (WINAPI *)(__VA_ARGS__)) GetProcAddress(opengl32, #NAME);
	GL10_FUNCTIONS
	#undef X
	#define X(RET, NAME, ...) NAME = cast(RET (WINAPI *)(__VA_ARGS__)) wglGetProcAddress(#NAME);
	GL20_FUNCTIONS
	GL30_FUNCTIONS
	GL42_FUNCTIONS
	GL45_FUNCTIONS
	#undef X
}

void opengl_platform_deinit(void) {
	if (opengl_ctx != null) wglDeleteContext(opengl_ctx);
	opengl_ctx = null;
}

void opengl_platform_present(void) {
	SwapBuffers(platform_hdc);
}
#endif

typedef u8 OpenGLRectIndex;
typedef struct {
	v2 position;
} OpenGLRectVertex;
typedef struct {
	v4 color;
	v4 texcoords; // xy=bottomleft zw=topright
	v2 offset;
	v2 scale;
	u32 texture_index;
} OpenGLRectInstance;

typedef u32 OpenGLModelIndex;
typedef struct {
	v3 position;
	v2 texcoord;
	u32 texture_index;
} OpenGLModelVertex;
typedef struct {
	m4 world_transform;
} OpenGLModelInstance;

u8 opengl_arena_backing[1024 * 1024 * 8];
Arena opengl_arena;

u32 opengl_main_fbo;
u32 opengl_main_fbo_color0;
u32 opengl_main_fbo_depth;

u32 opengl_white_texture;
u32 opengl_monocraft_texture;

OpenGLRectIndex opengl_rect_indices[] = {0, 1, 2, 2, 3, 0};
OpenGLRectVertex opengl_rect_vertices[] = {
	{.position = {-1.0f, -1.0f}},
	{.position = {+1.0f, -1.0f}},
	{.position = {+1.0f, +1.0f}},
	{.position = {-1.0f, +1.0f}},
};

OpenGLModelIndex opengl_triangle_model_indices[] = {0, 1, 2};
OpenGLModelVertex opengl_triangle_model_vertices[] = {
	{.position = {-0.5f, -0.5f, 0.0f}, .texcoord = {0.0f, 0.0f}, .texture_index = 1},
	{.position = {+0.5f, -0.5f, 0.0f}, .texcoord = {1.0f, 0.0f}, .texture_index = 1},
	{.position = {0.0f, +0.5f, 0.0f}, .texcoord = {0.5f, 1.0f}, .texture_index = 1},
};
OpenGLModelIndex opengl_rectangle_model_indices[] = {0, 1, 2, 2, 3, 0};
OpenGLModelVertex opengl_rectangle_model_vertices[] = {
	{.position = {-0.5f, -0.5f, 0.0f}, .texcoord = {0.0f, 0.0f}, .texture_index = 1},
	{.position = {+0.5f, -0.5f, 0.0f}, .texcoord = {1.0f, 0.0f}, .texture_index = 1},
	{.position = {+0.5f, +0.5f, 0.0f}, .texcoord = {1.0f, 1.0f}, .texture_index = 1},
	{.position = {-0.5f, +0.5f, 0.0f}, .texcoord = {0.0f, 1.0f}, .texture_index = 1},
};

OpenGLModelIndex model_kind_to_vbo_offset[] = {
	[MODEL_TRIANGLE] = 0,
	[MODEL_RECTANGLE] = 3,
};
OpenGLModelIndex model_kind_to_indices_count[] = {
	[MODEL_TRIANGLE] = 3,
	[MODEL_RECTANGLE] = 6,
};
OpenGLModelIndex* model_kind_to_indices[] = {
	[MODEL_TRIANGLE] = opengl_triangle_model_indices,
	[MODEL_RECTANGLE] = opengl_rectangle_model_indices,
};

#define MAX_RECTS_PER_DRAW_CALL 1024
u32 opengl_rect_shader;
u32 opengl_rect_vao;
u32 opengl_rect_vbo;
u32 opengl_rect_ebo;
u32 opengl_rect_ibo;

#define MAX_MODELS_PER_DRAW_CALL 1024
u32 opengl_model_shader;
u32 opengl_model_vao;
u32 opengl_model_vbo;
u32 opengl_model_ebo;
u32 opengl_model_ibo;

void opengl_init(void) {
	opengl_platform_init();

	opengl_arena = arena_init(opengl_arena_backing, size_of(opengl_arena_backing));

	glEnable(GL_FRAMEBUFFER_SRGB);
	glCreateFramebuffers(1, &opengl_main_fbo);
	glCreateRenderbuffers(1, &opengl_main_fbo_color0);
	glCreateRenderbuffers(1, &opengl_main_fbo_depth);

	{
		glCreateBuffers(1, &opengl_rect_vbo);
		glNamedBufferData(opengl_rect_vbo, size_of(opengl_rect_vertices), opengl_rect_vertices, GL_STATIC_DRAW);
		glCreateBuffers(1, &opengl_rect_ebo);
		glNamedBufferData(opengl_rect_ebo, size_of(opengl_rect_indices), opengl_rect_indices, GL_STATIC_DRAW);
		glCreateBuffers(1, &opengl_rect_ibo);
		glNamedBufferData(opengl_rect_ibo, size_of(OpenGLRectInstance) * MAX_RECTS_PER_DRAW_CALL, null, GL_STREAM_DRAW);

		u32 vbo_binding = 0;
		u32 ibo_binding = 1;
		glCreateVertexArrays(1, &opengl_rect_vao);
		glVertexArrayElementBuffer(opengl_rect_vao, opengl_rect_ebo);
		glVertexArrayVertexBuffer(opengl_rect_vao, vbo_binding, opengl_rect_vbo, 0, size_of(OpenGLRectVertex));
		glVertexArrayVertexBuffer(opengl_rect_vao, ibo_binding, opengl_rect_ibo, 0, size_of(OpenGLRectInstance));
		glVertexArrayBindingDivisor(opengl_rect_vao, ibo_binding, 1);

		u32 position_attrib = 0;
		glEnableVertexArrayAttrib(opengl_rect_vao, position_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, position_attrib, vbo_binding);
		glVertexArrayAttribFormat(opengl_rect_vao, position_attrib, 2, GL_FLOAT, false, offset_of(OpenGLRectVertex, position));

		u32 color_attrib = 1;
		glEnableVertexArrayAttrib(opengl_rect_vao, color_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, color_attrib, ibo_binding);
		glVertexArrayAttribFormat(opengl_rect_vao, color_attrib, 4, GL_FLOAT, false, offset_of(OpenGLRectInstance, color));

		u32 texcoords_attrib = 2;
		glEnableVertexArrayAttrib(opengl_rect_vao, texcoords_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, texcoords_attrib, ibo_binding);
		glVertexArrayAttribFormat(opengl_rect_vao, texcoords_attrib, 4, GL_FLOAT, false, offset_of(OpenGLRectInstance, texcoords));

		u32 offset_attrib = 3;
		glEnableVertexArrayAttrib(opengl_rect_vao, offset_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, offset_attrib, ibo_binding);
		glVertexArrayAttribFormat(opengl_rect_vao, offset_attrib, 2, GL_FLOAT, false, offset_of(OpenGLRectInstance, offset));

		u32 scale_attrib = 4;
		glEnableVertexArrayAttrib(opengl_rect_vao, scale_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, scale_attrib, ibo_binding);
		glVertexArrayAttribFormat(opengl_rect_vao, scale_attrib, 2, GL_FLOAT, false, offset_of(OpenGLRectInstance, scale));

		u32 texture_index_attrib = 5;
		glEnableVertexArrayAttrib(opengl_rect_vao, texture_index_attrib);
		glVertexArrayAttribBinding(opengl_rect_vao, texture_index_attrib, ibo_binding);
		glVertexArrayAttribIFormat(opengl_rect_vao, texture_index_attrib, 1, GL_UNSIGNED_INT, offset_of(OpenGLRectInstance, texture_index));

		string vsrc = platform_read_entire_file(S("res/shaders/rect.glsl.vert"), &opengl_arena);
		u32 vshader = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vshader, 1, &vsrc.data, null);
		glCompileShader(vshader);
		arena_reset(&opengl_arena);

		string fsrc = platform_read_entire_file(S("res/shaders/rect.glsl.frag"), &opengl_arena);
		u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fshader, 1, &fsrc.data, null);
		glCompileShader(fshader);
		arena_reset(&opengl_arena);

		opengl_rect_shader = glCreateProgram();
		glAttachShader(opengl_rect_shader, vshader);
		glAttachShader(opengl_rect_shader, fshader);
		glLinkProgram(opengl_rect_shader);
		glDetachShader(opengl_rect_shader, fshader);
		glDetachShader(opengl_rect_shader, vshader);

		for (s32 i = 0; i < 32; i += 1) glProgramUniform1i(opengl_rect_shader, i, i);
	}

	{
		glCreateBuffers(1, &opengl_model_vbo);
		glNamedBufferData(opengl_model_vbo, size_of(opengl_triangle_model_vertices) + size_of(opengl_rectangle_model_vertices), null, GL_STATIC_DRAW);
		glNamedBufferSubData(opengl_model_vbo, model_kind_to_vbo_offset[MODEL_TRIANGLE] * size_of(OpenGLModelVertex), size_of(opengl_triangle_model_vertices), opengl_triangle_model_vertices);
		glNamedBufferSubData(opengl_model_vbo, model_kind_to_vbo_offset[MODEL_RECTANGLE] * size_of(OpenGLModelVertex), size_of(opengl_rectangle_model_vertices), opengl_rectangle_model_vertices);
		glCreateBuffers(1, &opengl_model_ebo);
		glNamedBufferData(opengl_model_ebo, size_of(OpenGLModelIndex) * MAX_MODELS_PER_DRAW_CALL * 1024, null, GL_STREAM_DRAW);
		glCreateBuffers(1, &opengl_model_ibo);
		glNamedBufferData(opengl_model_ibo, size_of(OpenGLModelInstance) * MAX_MODELS_PER_DRAW_CALL, null, GL_STREAM_DRAW);

		u32 vbo_binding = 0;
		u32 ibo_binding = 1;
		glCreateVertexArrays(1, &opengl_model_vao);
		glVertexArrayElementBuffer(opengl_model_vao, opengl_model_ebo);
		glVertexArrayVertexBuffer(opengl_model_vao, vbo_binding, opengl_model_vbo, 0, size_of(OpenGLModelVertex));
		glVertexArrayVertexBuffer(opengl_model_vao, ibo_binding, opengl_model_ibo, 0, size_of(OpenGLModelInstance));
		glVertexArrayBindingDivisor(opengl_model_vao, ibo_binding, 1);

		u32 position_attrib = 0;
		glEnableVertexArrayAttrib(opengl_model_vao, position_attrib);
		glVertexArrayAttribBinding(opengl_model_vao, position_attrib, vbo_binding);
		glVertexArrayAttribFormat(opengl_model_vao, position_attrib, 3, GL_FLOAT, false, offset_of(OpenGLModelVertex, position));

		u32 texcoord_attrib = 1;
		glEnableVertexArrayAttrib(opengl_model_vao, texcoord_attrib);
		glVertexArrayAttribBinding(opengl_model_vao, texcoord_attrib, vbo_binding);
		glVertexArrayAttribFormat(opengl_model_vao, texcoord_attrib, 2, GL_FLOAT, false, offset_of(OpenGLModelVertex, texcoord));

		u32 texture_index_attrib = 2;
		glEnableVertexArrayAttrib(opengl_model_vao, texture_index_attrib);
		glVertexArrayAttribBinding(opengl_model_vao, texture_index_attrib, vbo_binding);
		glVertexArrayAttribIFormat(opengl_model_vao, texture_index_attrib, 1, GL_UNSIGNED_INT, offset_of(OpenGLModelVertex, texture_index));

		u32 world_transform_attrib = 3;
		for (s32 i = 0; i < 4; i += 1) {
			glEnableVertexArrayAttrib(opengl_model_vao, world_transform_attrib + i);
			glVertexArrayAttribBinding(opengl_model_vao, world_transform_attrib + i, ibo_binding);
			glVertexArrayAttribFormat(opengl_model_vao, world_transform_attrib + i, 4, GL_FLOAT, false, offset_of(OpenGLModelInstance, world_transform) + i * size_of(v4));
		}

		string vsrc = platform_read_entire_file(S("res/shaders/model.glsl.vert"), &opengl_arena);
		u32 vshader = glCreateShader(GL_VERTEX_SHADER);
		glShaderSource(vshader, 1, &vsrc.data, null);
		glCompileShader(vshader);
		arena_reset(&opengl_arena);

		string fsrc = platform_read_entire_file(S("res/shaders/model.glsl.frag"), &opengl_arena);
		u32 fshader = glCreateShader(GL_FRAGMENT_SHADER);
		glShaderSource(fshader, 1, &fsrc.data, null);
		glCompileShader(fshader);
		arena_reset(&opengl_arena);

		opengl_model_shader = glCreateProgram();
		glAttachShader(opengl_model_shader, vshader);
		glAttachShader(opengl_model_shader, fshader);
		glLinkProgram(opengl_model_shader);
		glDetachShader(opengl_model_shader, fshader);
		glDetachShader(opengl_model_shader, vshader);

		for (s32 i = 0; i < 32; i += 1) glProgramUniform1i(opengl_model_shader, i, i);
	}

	glCreateTextures(GL_TEXTURE_2D, 1, &opengl_white_texture);
	glTextureStorage2D(opengl_white_texture, 1, GL_RGBA8, 1, 1);
	u32 white_pixel = 0xFFFFFFFF;
	glTextureSubImage2D(opengl_white_texture, 0, 0, 0, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, &white_pixel);

	string bmp_file = platform_read_entire_file(S("res/textures/monocraft.bmp"), &opengl_arena);
	u32 bmp_pixels_offset = *cast(u32*) (bmp_file.data + 0x0A);
	s32 bmp_width = *cast(s32*) (bmp_file.data + 0x12);
	s32 bmp_height = *cast(s32*) (bmp_file.data + 0x16);
	u32* bmp_pixels = cast(u32*) (bmp_file.data + bmp_pixels_offset);
	glCreateTextures(GL_TEXTURE_2D, 1, &opengl_monocraft_texture);
	glTextureStorage2D(opengl_monocraft_texture, 1, GL_RGBA8, bmp_width, bmp_height);
	glTextureSubImage2D(opengl_monocraft_texture, 0, 0, 0, bmp_width, bmp_height, GL_BGRA, GL_UNSIGNED_BYTE, bmp_pixels);
	arena_reset(&opengl_arena);
}

void opengl_deinit(void) {
	opengl_platform_deinit();
}

void opengl_resize(void) {
	if (platform_width <= 0 || platform_height <= 0) return;

	s32 fbo_color_samples_max;
	glGetIntegerv(GL_MAX_COLOR_TEXTURE_SAMPLES, &fbo_color_samples_max);
	s32 fbo_depth_samples_max;
	glGetIntegerv(GL_MAX_DEPTH_TEXTURE_SAMPLES, &fbo_depth_samples_max);
	s32 fbo_samples = min(fbo_color_samples_max, fbo_depth_samples_max);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_color0, fbo_samples, GL_RGBA16F, platform_width, platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, opengl_main_fbo_color0);

	glNamedRenderbufferStorageMultisample(opengl_main_fbo_depth, fbo_samples, GL_DEPTH_COMPONENT32F, platform_width, platform_height);
	glNamedFramebufferRenderbuffer(opengl_main_fbo, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, opengl_main_fbo_depth);
}

void opengl_present(GameRenderer* game_renderer) {
	if (platform_width <= 0 || platform_height <= 0) return;

	glClearNamedFramebufferfv(opengl_main_fbo, GL_COLOR, 0, &game_renderer->clear_color0.x);
	glClearNamedFramebufferfv(opengl_main_fbo, GL_DEPTH, 0, &game_renderer->clear_depth);

	glBindFramebuffer(GL_FRAMEBUFFER, opengl_main_fbo);
	glViewport(0, 0, platform_width, platform_height);

	arena_reset(&opengl_arena);

	s32 platform_width_divisor = max(1, platform_width - 1);
	s32 platform_height_divisor = max(1, platform_height - 1);

	OpenGLModelInstance* model_instances = arena_alloc(&opengl_arena, size_of(OpenGLModelInstance) * MAX_MODELS_PER_DRAW_CALL);
	s32 model_instances_count = 0;
	OpenGLRectInstance* rect_instances = arena_alloc(&opengl_arena, size_of(OpenGLRectInstance) * MAX_RECTS_PER_DRAW_CALL);
	s32 rect_instances_count = 0;
	OpenGLModelIndex* model_indices = arena_alloc(&opengl_arena, size_of(OpenGLModelIndex) * MAX_MODELS_PER_DRAW_CALL * 1024);
	s32 model_indices_count = 0;
	for (GameRenderCommand* command = game_renderer->commands_arena.base;
		cast(u8*) command < cast(u8*) game_renderer->commands_arena.base + game_renderer->commands_arena.size;
		command += 1)
	{
		switch (command->kind) {
			case RENDER_COMMAND_NOOP: assert(0); break;
			case RENDER_COMMAND_RECT: {
				OpenGLRectInstance* instance = &rect_instances[rect_instances_count++];
				instance->color = command->u.rect.color;
				instance->texcoords = command->u.rect.texcoords;
				f32 x = command->u.rect.offset_and_scale.x / platform_width_divisor * 2.0f - 1.0f;
				f32 y = command->u.rect.offset_and_scale.y / platform_height_divisor * 2.0f - 1.0f;
				f32 w = command->u.rect.offset_and_scale.z / platform_width_divisor;
				f32 h = command->u.rect.offset_and_scale.w / platform_height_divisor;
				instance->offset = (v2) {x + w, y + h};
				instance->scale = (v2) {w, h};
				instance->texture_index = command->u.rect.texture_index;
			} break;
			case RENDER_COMMAND_MODEL: {
				OpenGLModelInstance* instance = &model_instances[model_instances_count++];
				OpenGLModelIndex base_index = model_kind_to_vbo_offset[command->u.model.kind];
				for (OpenGLModelIndex i = 0; i < model_kind_to_indices_count[command->u.model.kind]; i += 1) {
					OpenGLModelIndex* index = &model_indices[model_indices_count++];
					*index = base_index + model_kind_to_indices[command->u.model.kind][i];
				}
				instance->world_transform = command->u.model.world_transform;
			} break;
			default: assert(0); break;
		}
	}
	glNamedBufferSubData(opengl_model_ebo, 0, model_indices_count * size_of(OpenGLModelIndex), model_indices);
	glNamedBufferSubData(opengl_model_ibo, 0, model_instances_count * size_of(OpenGLModelInstance), model_instances);
	glNamedBufferSubData(opengl_rect_ibo, 0, rect_instances_count * size_of(OpenGLRectInstance), rect_instances);
	arena_reset(&opengl_arena);

	glDisable(GL_BLEND);
	glUseProgram(opengl_model_shader);
	glBindVertexArray(opengl_model_vao);
	glDrawElementsInstancedBaseVertexBaseInstance(
		GL_TRIANGLES,
		model_indices_count,
		GL_UNSIGNED_INT,
		cast(void*) 0,
		model_instances_count,
		0, 0);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBindTextureUnit(0, opengl_white_texture);
	glBindTextureUnit(1, opengl_monocraft_texture);
	glUseProgram(opengl_rect_shader);
	glBindVertexArray(opengl_rect_vao);
	glDrawElementsInstancedBaseVertexBaseInstance(
		GL_TRIANGLES,
		len(opengl_rect_indices),
		GL_UNSIGNED_BYTE,
		cast(void*) 0,
		rect_instances_count,
		0, 0);

	glBindFramebuffer(GL_FRAMEBUFFER, 0);

	glBlitNamedFramebuffer(opengl_main_fbo, 0,
		0, 0, platform_width, platform_height,
		0, 0, platform_width, platform_height,
		GL_COLOR_BUFFER_BIT, GL_NEAREST);
	opengl_platform_present();
}
