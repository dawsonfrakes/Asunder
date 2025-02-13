Vector :: struct (N: s64, T: Type) {
	#assert(N >= 1);

	x: T;
	#if N >= 2 y: T;
	#if N >= 3 z: T;
	#if N >= 4 w: T;

	#place x;
	r: T;
	#if N >= 2 g: T;
	#if N >= 3 b: T;
	#if N >= 4 a: T;

	#place x;
	elements: [N]T;
}
v4 :: Vector(4, float32);

max :: inline (a: $A, b: A) -> A { return ifx a > b then a else b; }

slice :: inline (array: []$T, start: s64) -> []T {
	return slice(array, start, array.count - start);
}

slice :: inline (array: []$T, start: s64, end: s64) -> []T {
	result : []T = ---;
	result.data = array.data + start;
	result.count = end - start;
	return result;
}
