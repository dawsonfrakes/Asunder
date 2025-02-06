import pathlib

pathlib.Path("gen").mkdir(exist_ok=True)

with open("gen/enums.h", "w") as f:
	f.write("typedef enum GameModelKind {\n")
	f.write("  MODEL_INVALID = 0,\n")
	for i, fpath in enumerate(pathlib.Path("res/models").iterdir()):
		if fpath.is_file():
				f.write("  MODEL_" + fpath.stem.upper() + f" = {i + 1},\n")
	f.write("} GameModelKind;\n")
