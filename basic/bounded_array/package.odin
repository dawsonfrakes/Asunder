package bounded_array

import "base:builtin"

Bounded_Array :: struct (N: int, T: typeid) {
  _buffer: [N]T,
  _len: int,
}

len :: proc(barray: ^Bounded_Array($N, $T)) -> int {
  return barray._len
}

cap :: proc(barray: ^Bounded_Array($N, $T)) -> int {
  return len(barray._buffer)
}

append :: proc(barray: ^Bounded_Array($N, $T), items: ..T, loc := #caller_location) -> (n: int) #no_bounds_check {
  assert(barray._len + builtin.len(items) <= N, loc = loc)
  n = barray._len
  for item in items {
    barray._buffer[barray._len] = item
    barray._len += 1
  }
  return
}

ba_slice_range :: proc(barray: Bounded_Array($N, $T), start: int, end: int) -> []T {
  barray := barray
  assert(start <= barray._len);
  assert(end <= barray._len);
  return barray._buffer[start:end]
}

ba_slice_begin :: proc(barray: Bounded_Array($N, $T), start := 0) -> []T {
  return ba_slice_range(barray, start, barray._len)
}

slice :: proc{ba_slice_begin, ba_slice_range}
