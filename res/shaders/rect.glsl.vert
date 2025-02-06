#version 450

layout(location = 0) in vec2 a_position;
layout(location = 1) in vec4 i_color;
layout(location = 2) in vec4 i_texcoords;
layout(location = 3) in vec2 i_offset;
layout(location = 4) in vec2 i_scale;
layout(location = 5) in uint i_texture_index;

layout(location = 1) out vec4 f_color;
layout(location = 2) out vec2 f_texcoord;
layout(location = 5) out flat uint f_texture_index;

void main() {
	gl_Position = vec4(a_position * i_scale + i_offset, 0.0, 1.0);
	f_color = i_color;
	f_texcoord = vec2(
		mix(i_texcoords.x, i_texcoords.z, float((gl_VertexID + 1) / 2 == 1)),
		mix(i_texcoords.y, i_texcoords.w, float(gl_VertexID / 2 == 1)));
	f_texture_index = i_texture_index;
}
