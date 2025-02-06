#version 450

layout(location = 0) in vec3 a_position;
layout(location = 1) in vec2 a_texcoord;
layout(location = 2) in uint a_texture_index;
layout(location = 3) in mat4 i_world_transform;

layout(location = 1) out vec2 f_texcoord;
layout(location = 2) out flat uint f_texture_index;

void main() {
	gl_Position = i_world_transform * vec4(a_position, 1.0);
	f_texcoord = a_texcoord;
	f_texture_index = a_texture_index;
}
