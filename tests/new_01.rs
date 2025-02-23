fn f(n: i32) -> i32 {
    n
}

fn g(x: i32) {
    x = f(1i32) // BAD : cannot assign to immutable argument
}
