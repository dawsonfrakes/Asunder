min :: inline (a: $T, b: T) -> T #no_context { return ifx a < b then a else b; }
max :: inline (a: $T, b: T) -> T #no_context { return ifx a > b then a else b; }
