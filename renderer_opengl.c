typedef intptr_t GLintptr;
typedef uintptr_t GLsizeiptr;

#define GL_FUNCTIONS \
	X(void, ClipControl, GLenum, GLenum) \
	X(void, CreateVertexArrays, GLsizei, GLuint *) \
	X(void, VertexArrayVertexBuffer, GLuint, GLuint, GLuint, GLintptr, GLsizei) \
	X(void, VertexArrayElementBuffer, GLuint, GLuint) \
	X(void, VertexArrayAttribBinding, GLuint, GLuint, GLuint) \
	X(void, VertexArrayAttribFormat, GLuint, GLuint, GLint, GLenum, GLboolean, GLuint) \
	X(void, EnableVertexArrayAttrib, GLuint, GLuint) \
	X(void, BindVertexArray, GLuint) \
	X(void, CreateBuffers, GLsizei, GLuint *) \
	X(void, NamedBufferStorage, GLuint, GLsizeiptr, const void *, GLbitfield) \
	X(void, NamedBufferSubData, GLuint, GLintptr, GLsizei, const void *) \
	X(void, CreateProgramPipelines, GLsizei, GLuint *) \
	X(void, UseProgramStages, GLuint, GLbitfield, GLuint) \
	X(GLuint, CreateShaderProgramv, GLenum, GLsizei, const char **) \
	X(void, BindProgramPipeline, GLuint)

#define X(RET, NAME, ...) RET (*gl ## NAME)(__VA_ARGS__);
GL_FUNCTIONS
#undef X

#define WGL_CONTEXT_MAJOR_VERSION_ARB 0x2091
#define WGL_CONTEXT_MINOR_VERSION_ARB 0x2092
#define WGL_CONTEXT_FLAGS_ARB 0x2094
#define WGL_CONTEXT_PROFILE_MASK_ARB 0x9126
#define WGL_CONTEXT_DEBUG_BIT_ARB 0x0001
#define WGL_CONTEXT_CORE_PROFILE_BIT_ARB 0x00000001
#define GL_DYNAMIC_STORAGE_BIT 0x0100
#define GL_VERTEX_SHADER_BIT 0x00000001
#define GL_FRAGMENT_SHADER_BIT 0x00000002
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31
#define GL_LOWER_LEFT 0x8CA1
#define GL_ZERO_TO_ONE 0x935F

struct Graphics {
	struct Vertex {
		v3 position;
		v4 color;
	} *vertices;
	uint16_t vertices_count;
	uint16_t vertices_max;

	uint16_t *indices;
	uint16_t indices_count;
	uint16_t indices_max;

	GLuint vbo;

	v2 screen;

	#if 1 /* windows */
	HDC hdc;
	#endif
};

static void
renderer_init(struct Graphics *gfx, HDC hdc)
{
	static PIXELFORMATDESCRIPTOR pfd;
	static HGLRC                 context;
	static HGLRC (*wglCreateContextAttribsARB)(HDC, HGLRC, const int *);
	static int (*wglSwapIntervalEXT)(int);
	static const int attribs[] = {
		WGL_CONTEXT_MAJOR_VERSION_ARB, 4,
		WGL_CONTEXT_MINOR_VERSION_ARB, 5,
		WGL_CONTEXT_PROFILE_MASK_ARB, WGL_CONTEXT_CORE_PROFILE_BIT_ARB,
		WGL_CONTEXT_FLAGS_ARB, WGL_CONTEXT_DEBUG_BIT_ARB, /* @debug */
		0,
	};

	gfx->hdc = hdc;

	pfd.nSize        = sizeof(pfd);
	pfd.nVersion     = 1;
	pfd.dwFlags      = PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER;
	pfd.cColorBits   = 32;
	pfd.cDepthBits   = 24;
	pfd.cStencilBits = 8;
	SetPixelFormat(gfx->hdc, ChoosePixelFormat(gfx->hdc, &pfd), &pfd);
	context = wglCreateContext(gfx->hdc);
	wglMakeCurrent(gfx->hdc, context);
	wglCreateContextAttribsARB = (HGLRC (*)(HDC, HGLRC, const int *))
	                             wglGetProcAddress("wglCreateContextAttribsARB");
	wglDeleteContext(context);
	context = wglCreateContextAttribsARB(gfx->hdc, 0, attribs);
	wglMakeCurrent(gfx->hdc, context);
	wglSwapIntervalEXT = (int (*)(int)) wglGetProcAddress("wglSwapIntervalEXT");
	wglSwapIntervalEXT(1); /* vsync enable */

#define X(RET, NAME, ...) gl ## NAME = (RET (*)(__VA_ARGS__)) wglGetProcAddress("gl" #NAME);
	GL_FUNCTIONS
#undef X

	glClipControl(GL_LOWER_LEFT, GL_ZERO_TO_ONE);

	{
		static const char *vsrc =
		"#version 450 core\n"
		"layout (location = 0) in vec3 a_position;"
		"layout (location = 1) in vec4 a_color;"
		"layout (location = 0) out vec4 f_color;"
		"out gl_PerVertex { vec4 gl_Position; };"
		"void main() {"
		"	f_color = a_color;"
		"	gl_Position = vec4(a_position.xy, -a_position.z / 100.0, -a_position.z);"
		"}";
		static const char *fsrc =
		"#version 450 core\n"
		"layout (location = 0) in vec4 f_color;"
		"layout (location = 0) out vec4 color;"
		"void main() {"
		"	color = f_color;"
		"}";
		GLuint pipeline;

		GLuint vao;
		GLuint vbo_binding = 0;
		GLuint position_attrib = 0;
		GLuint color_attrib = 1;

		glCreateProgramPipelines(1, &pipeline);
		glUseProgramStages(pipeline, GL_VERTEX_SHADER_BIT, glCreateShaderProgramv(GL_VERTEX_SHADER, 1, &vsrc));
		glUseProgramStages(pipeline, GL_FRAGMENT_SHADER_BIT, glCreateShaderProgramv(GL_FRAGMENT_SHADER, 1, &fsrc));
		glBindProgramPipeline(pipeline);

		/* MAJOR @Cleanup */
		gfx->vertices_max = 1024;
		gfx->vertices = VirtualAlloc(0, gfx->vertices_max * sizeof(struct Vertex),
		MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);

		gfx->indices_max = 1024*3;
		gfx->indices = VirtualAlloc(0, gfx->indices_max * sizeof(uint16_t),
		MEM_RESERVE | MEM_COMMIT, PAGE_READWRITE);

		glCreateBuffers(1, &gfx->vbo);
		glNamedBufferStorage(gfx->vbo, gfx->indices_max * sizeof(uint16_t) + gfx->vertices_max * sizeof(struct Vertex), 0, GL_DYNAMIC_STORAGE_BIT);

		glCreateVertexArrays(1, &vao);
		glVertexArrayVertexBuffer(vao, vbo_binding, gfx->vbo, gfx->indices_max * sizeof(uint16_t), sizeof(struct Vertex));
		glVertexArrayElementBuffer(vao, gfx->vbo);
		glVertexArrayAttribBinding(vao, position_attrib, vbo_binding);
		glVertexArrayAttribFormat(vao, position_attrib, 3, GL_FLOAT, GL_FALSE, OFFSETOF(struct Vertex, position));
		glEnableVertexArrayAttrib(vao, position_attrib);
		glVertexArrayAttribBinding(vao, color_attrib, vbo_binding);
		glVertexArrayAttribFormat(vao, color_attrib, 4, GL_FLOAT, GL_FALSE, OFFSETOF(struct Vertex, color));
		glEnableVertexArrayAttrib(vao, color_attrib);
		glBindVertexArray(vao);
	}
}

static void
renderer_resize(struct Graphics *gfx, uint16_t screen_width, uint16_t screen_height)
{
	gfx->screen = make_v2((float) screen_width,
	                      (float) screen_height);
	glViewport(0, 0, screen_width, screen_height);
}

static void
renderer_swap(struct Graphics *gfx)
{
	glNamedBufferSubData(gfx->vbo, 0, gfx->indices_count * sizeof(uint16_t), gfx->indices);
	glNamedBufferSubData(gfx->vbo, gfx->indices_max * sizeof(uint16_t), gfx->vertices_count * sizeof(struct Vertex), gfx->vertices);
	glDrawElements(GL_TRIANGLES, gfx->indices_count, GL_UNSIGNED_SHORT, 0);
	gfx->vertices_count = 0;
	gfx->indices_count = 0;
	SwapBuffers(gfx->hdc);
}

static void
renderer_clear(struct Graphics *gfx, v4 color)
{
	(void) gfx;
	glClearColor(color.x, color.y, color.z, color.w);
	glClear(GL_COLOR_BUFFER_BIT);
}

static void
renderer_tri(struct Graphics *gfx, struct Vertices *vertices)
{
	uint16_t base_index;
	uint8_t it_index;
	struct Vertex *vertex;
	uint16_t *index;

	base_index = gfx->vertices_count;
	for (it_index = 0; it_index < 3; ++it_index) {
		index = gfx->indices + gfx->indices_count++;
		vertex = gfx->vertices + gfx->vertices_count++;

		vertex->position = vertices->pos[it_index];
		vertex->color    = vertices->color[it_index];

		*index = base_index + it_index;
	}
}
