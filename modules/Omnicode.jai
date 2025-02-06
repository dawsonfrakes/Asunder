#import "Basic";

ascii_to_utf16lez :: (s: string, allocator := context.allocator) -> []u16 {
	result: [..]u16;
	result.allocator = allocator;
	for s array_add(*result, it);
	array_add(*result, 0);
	return result;
}
