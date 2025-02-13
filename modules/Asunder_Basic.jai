slice :: inline (array: []$T, start: s64) -> []T {
	return slice(array, start, array.count - start);
}

slice :: inline (array: []$T, start: s64, end: s64) -> []T {
	result : []T = ---;
	result.data = array.data + start;
	result.count = end - start;
	return result;
}
