struct S {}

fn f(x: S) {}

fn g(x: S) {
    f(x);
    f(x); // BAD : x uninitialized at this point
}
