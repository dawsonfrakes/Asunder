// 1.0
#define GL_COLOR_BUFFER_BIT 0x00004000
#define GL_TRIANGLES 0x0004
#define GL_GEQUAL 0x0206
#define GL_SRC_ALPHA 0x0302
#define GL_ONE_MINUS_SRC_ALPHA 0x0303
#define GL_FRONT_AND_BACK 0x0408
#define GL_CULL_FACE 0x0B44
#define GL_DEPTH_TEST 0x0B71
#define GL_BLEND 0x0BE2
#define GL_TEXTURE_2D 0x0DE1
#define GL_UNSIGNED_BYTE 0x1401
#define GL_UNSIGNED_SHORT 0x1403
#define GL_UNSIGNED_INT 0x1405
#define GL_FLOAT 0x1406
#define GL_COLOR 0x1800
#define GL_DEPTH 0x1801
#define GL_RGB 0x1907
#define GL_RGBA 0x1908
#define GL_POINT 0x1B00
#define GL_LINE 0x1B01
#define GL_FILL 0x1B02
#define GL_NEAREST 0x2600
#define GL_LINEAR 0x2601

#define GL10_FUNCTIONS \
	X(void, glEnable, u32) \
	X(void, glDisable, u32) \
	X(void, glViewport, s32, s32, u32, u32) \
	X(void, glGetIntegerv, u32, s32*) \
	X(void, glBlendFunc, u32, u32)

// 1.1
#define GL_RGBA8 0x8058

// 1.2
#define GL_BGR 0x80E0
#define GL_BGRA 0x80E1

// 1.5
#define GL_STREAM_DRAW 0x88E0
#define GL_STATIC_DRAW 0x88E4

// 2.0
#define GL_FRAGMENT_SHADER 0x8B30
#define GL_VERTEX_SHADER 0x8B31

#define GL20_FUNCTIONS \
	X(u32, glCreateProgram, void) \
	X(void, glAttachShader, u32, u32) \
	X(void, glDetachShader, u32, u32) \
	X(void, glLinkProgram, u32) \
	X(void, glUseProgram, u32) \
	X(u32, glCreateShader, u32) \
	X(void, glShaderSource, u32, u32, u8**, s32*) \
	X(void, glCompileShader, u32)

// 3.0
#define GL_RGBA16F 0x881A
#define GL_DEPTH_COMPONENT32F 0x8CAC
#define GL_COLOR_ATTACHMENT0 0x8CE0
#define GL_DEPTH_ATTACHMENT 0x8D00
#define GL_FRAMEBUFFER 0x8D40
#define GL_RENDERBUFFER 0x8D41
#define GL_FRAMEBUFFER_SRGB 0x8DB9

#define GL30_FUNCTIONS \
	X(void, glBindFramebuffer, u32, u32) \
	X(void, glBindVertexArray, u32)

// 3.2
#define GL_MAX_COLOR_TEXTURE_SAMPLES 0x910E
#define GL_MAX_DEPTH_TEXTURE_SAMPLES 0x910F

// 4.2
#define GL42_FUNCTIONS \
	X(void, glDrawElementsInstancedBaseVertexBaseInstance, u32, u32, u32, void*, u32, s32, u32)

// 4.5
#define GL45_FUNCTIONS \
	X(void, glCreateFramebuffers, u32, u32*) \
	X(void, glNamedFramebufferRenderbuffer, u32, u32, u32, u32) \
	X(void, glClearNamedFramebufferfv, u32, u32, s32, f32*) \
	X(void, glBlitNamedFramebuffer, u32, u32, s32, s32, s32, s32, s32, s32, s32, s32, u32, u32) \
	X(void, glCreateRenderbuffers, u32, u32*) \
	X(void, glNamedRenderbufferStorageMultisample, u32, u32, u32, u32, u32) \
	X(void, glCreateVertexArrays, u32, u32*) \
	X(void, glVertexArrayElementBuffer, u32, u32) \
	X(void, glVertexArrayVertexBuffer, u32, u32, u32, s64, u32) \
	X(void, glVertexArrayBindingDivisor, u32, u32, u32) \
	X(void, glEnableVertexArrayAttrib, u32, u32) \
	X(void, glVertexArrayAttribBinding, u32, u32, u32) \
	X(void, glVertexArrayAttribFormat, u32, u32, s32, u32, bool, u32) \
	X(void, glVertexArrayAttribIFormat, u32, u32, s32, u32, u32) \
	X(void, glCreateBuffers, u32, u32*) \
	X(void, glNamedBufferData, u32, u64, void*, u32) \
	X(void, glNamedBufferSubData, u32, s64, u64, void*) \
	X(void, glCreateTextures, u32, u32, u32*) \
	X(void, glTextureStorage2D, u32, u32, u32, u32, u32) \
	X(void, glTextureSubImage2D, u32, s32, s32, s32, u32, u32, u32, u32, void*) \
	X(void, glBindTextureUnit, u32, u32) \
	X(void, glProgramUniform1i, u32, s32, s32)
