#version 450

layout(location = 1) in vec4 f_color;
layout(location = 2) in vec2 f_texcoord;
layout(location = 5) in flat uint f_texture_index;

layout(location = 0) out vec4 color;

layout(location = 0) uniform sampler2D u_textures[32];

void main() {
	color = texture(u_textures[f_texture_index], f_texcoord) * f_color;
}
