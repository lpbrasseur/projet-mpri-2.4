struct S<'a> {
    b: &'a mut i32
}

fn f<'a, 'b, 'c, 'd>(x : &'c S<'a>) -> &'d S<'b> where 'b: 'a, 'a: 'b, 'd: 'c {
    x // BAD : we cannot cast [&'c S<'a>] into [&'d S<'b>] because we don't know 'c: 'd.
}
