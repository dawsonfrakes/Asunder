package game

Rect_Texture :: enum {
  WHITE = 0,
  FONT = 1,
}

Renderer_Procs :: struct {
  clear: proc(color0: [4]f32, depth: f32),
  rect: proc(position: [2]f32, size: [2]f32, color: [4]f32, texcoords: [2][2]f32, rotation: f32, texture: Rect_Texture),
}

Renderer :: struct {
  using procs: Renderer_Procs,
}

Font :: struct {
  size: f32,
  line_height: f32,
  base: f32,
  ascent: f32,
  descent: f32,
  width: f32,
  height: f32,
  characters: [256]struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    xoffset: f32,
    yoffset: f32,
    xadvance: f32,
  },
}

rect :: proc(renderer: ^Renderer, position: [2]f32, size: [2]f32, color: [4]f32, rotation: f32 = 0.0) {
  renderer.rect(position, size, color, {{0.0, 0.0}, {1.0, 1.0}}, rotation, .WHITE)
}

trect :: proc(renderer: ^Renderer, texture: Rect_Texture, position: [2]f32, size: [2]f32, texcoords: [2][2]f32, color: [4]f32 = 1.0, rotation: f32 = 0.0) {
  renderer.rect(position, size, color, texcoords, rotation, texture)
}

text :: proc(renderer: ^Renderer, s: string, position: [2]f32, scale: f32 = 1.0, color: [4]f32 = 1.0) {
  if len(s) == 0 do return

  x := position.x - mikado.characters[s[0]].width / 2 * scale
  y := position.y + (mikado.size - mikado.base) / 2 * scale
  for ch in s {
    if ch >= 256 do continue
    c := mikado.characters[ch]
    x += c.width / 2 * scale
    if ch != ' ' {
      x1 := c.x / (mikado.width - 1)
      y1 := 1.0 - c.y / (mikado.height - 1)
      x2 := (c.x + c.width) / (mikado.width - 1)
      y2 := 1.0 - (c.y + c.height) / (mikado.height - 1)
      trect(renderer, .FONT, {x + c.xoffset / 2 * scale, y - c.yoffset / 2 * scale}, {c.width * scale, c.height * scale}, {{x1, y2}, {x2, y1}}, color)
    }
    x += c.xadvance * scale - c.width / 2 * scale
  }
}
