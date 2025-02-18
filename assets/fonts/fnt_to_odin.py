import os, pathlib, sys, shlex

info = None
common = None
chars = {}
with open(sys.argv[1]) as f: src = f.read()
lines = src.strip().split("\n")
for line in lines:
  kind, *assigns = shlex.split(line.strip())
  kv = {}
  for assign in assigns:
    key, value = assign.strip().split("=")
    kv[key] = value
  if kind == "info": info = kv
  if kind == "common": common = kv
  if kind == "char": chars.update({kv["id"]: kv})

with open(pathlib.Path(sys.argv[1]).stem + ".odin", "w") as f:
  f.write("package fonts\n\n")
  f.write(pathlib.Path(sys.argv[1]).stem + " := Font{\n")
  f.write(f"\tsize = {info['size']},\n")
  f.write(f"\tline_height = {common['lineHeight']},\n")
  f.write(f"\tbase = {common['base']},\n")
  f.write(f"\tascent = {common['ascent']},\n")
  f.write(f"\tdescent = {common['descent']},\n")
  f.write(f"\tw = {common['scaleW']},\n")
  f.write(f"\th = {common['scaleH']},\n")
  f.write(f"\tcharacters = {{\n")
  for char in chars:
    f.write(f"\t\t{char} = {{x = {chars[char]['x']}, y = {chars[char]['y']}, w = {chars[char]['width']}, h = {chars[char]['height']}, xoff = {chars[char]['xoffset']}, yoff = {chars[char]['yoffset']}, xadvance = {chars[char]['xadvance']}}},\n")
  f.write(f"\t}}\n")
  f.write(f"}}\n")
