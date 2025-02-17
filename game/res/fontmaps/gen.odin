package gen

import "core:fmt"
import "core:strings"
import "core:os"

main :: proc() {
	file, success := os.read_entire_file("game/res/fontmaps/inconsolata.fnt")
	if !success {
		fmt.println("I have failed you :( (didn't find font file)")
		return
	}

	lines, err := strings.split(string(file), "\n")
	for line in lines {
		res, err := strings.split(line, " ")
		for assignment in res[1:] {
			kv, err := strings.split(assignment, "=")
			fmt.println(kv)
		}
		fmt.println(res)
	}
}
