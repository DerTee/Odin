package math_fixed_tests

import "core:fmt"
import "core:math/fixed"
import "core:testing"
import tc "tests:common"

main :: proc() {
    t := testing.T{}

    test_init_from_f64_and_back(&t)
    test_init_from_parts(&t)
    tc.report(&t)
}

@(test)
test_init_from_f64_and_back :: proc(t: ^testing.T) {
    Testcase :: struct{ input: f64 }
    testcases :: []Testcase{
        {0,},
        {0.25,},
        {0.5,},
        {1,},
        {2,},
        {-1,},
        {-2,},
        {-1000,},
        }
    for data in testcases {
        input := data.input
        fixed_num : fixed.Fixed16_16
        fixed.init_from_f64(&fixed_num, 0)
        output := fixed.to_f64(fixed_num)
        tc.expect(t, output == input, fmt.tprintf("%s(%f) -> got %b, expected %b", #procedure, input, transmute(u64)output, transmute(u64)input))
    }
}

@(test)
test_init_from_parts :: proc(t: ^testing.T) {
}