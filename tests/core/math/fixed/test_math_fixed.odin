package math_fixed_tests

import "core:strings"
import "core:fmt"
import "core:math/fixed"
import "core:testing"
import tc "tests:common"

main :: proc() {
    t := testing.T{}

    test_init_from_f64_and_back(&t)
    test_init_from_parts(&t)
    test_to_string(&t)
    tc.report(&t)
}

@(test)
test_init_from_f64_and_back :: proc(t: ^testing.T) {
    Testcase :: struct{ input: f64 }
    testcases :: []Testcase{
        {0},
        {0.25},
        {0.5},
        {1},
        {2},
        {1000},
        {-0.25},
        {-0.5},
        {-1},
        {-2},
        {-1000},
        }
    for data in testcases {
        input := data.input
        fixed_num : fixed.Fixed16_16
        fixed.init_from_f64(&fixed_num, 0)
        output := fixed.to_f64(fixed_num)
        // tc.expect(t, output == input, fmt.tprintf("%s(%f) -> got %b, expected %b", #procedure, input, transmute(u64)output, transmute(u64)input))
        tc.expect(
            t, output == input,
            fmt.tprintf("%s(%f) -> got %f, expected %f", #procedure, input, output, input))
    }
}

@(test)
test_init_from_parts :: proc(t: ^testing.T) {
    Testcase :: struct{ input_int: i32, input_fraction: i32, expected: string }
    testcases :: []Testcase{
        {input_int= 0, input_fraction = 0, expected = "0"},
        {input_int= -1, input_fraction = 0, expected = "-1"},
        {input_int= 8, input_fraction = 29, expected = "8.29"},
        {input_int= -8000, input_fraction = 1866, expected = "-8000.1866"},
        {input_int= -2, input_fraction = -6, expected = "-2.6"},
        {input_int= 2, input_fraction = -6, expected = "2.6"},
        }
    for data in testcases {
        fixed_num : fixed.Fixed16_16
        fixed.init_from_parts(&fixed_num, data.input_int, data.input_fraction)
        output := fixed.to_string(fixed_num)
        tc.expect(t,
            output == data.expected,
            fmt.tprintf(
                "%s(%i,%i) -> got %v, expected %v",
                #procedure, data.input_int, data.input_fraction,
                output, data.expected))
    }
}

@(test)
test_to_string :: proc(t: ^testing.T) {
    Testcase :: struct{
        input_f64: f64, input_int: i32, input_fraction: i32, expected: string, expected_float: string }
    testcases :: []Testcase{
        {0,             0,              0,                   "0", "0"},
        {-1,            -1,             0,                   "-1", "-1"},
        {8.29,          8,              29,                  "8.29", "8.29999"},
        {-8000.1866,    -8000,          1866,                "-8000.1866", ""},
        {-2.6,            -2,             -6,                "-2.6", "-2.6"},
        {2.6,             2,              -6,                "2.6", "2.6"},
        }
    for data in testcases {
        fixed_num_parts, fixed_num_f64 : fixed.Fixed16_16
        fixed.init_from_parts(&fixed_num_parts, data.input_int, data.input_fraction)
        fixed.init_from_f64(&fixed_num_f64, data.input_f64)
        output_parts := fixed.to_string(fixed_num_parts)
        output_f64 := fixed.to_string(fixed_num_f64)
        tc.expect(t,
            strings.contains(output_f64, data.expected_float) && output_parts == data.expected,
            fmt.tprintf(
                "%s(%f  %i,%i) -> got %v and %v, expected %v",
                #procedure, data.input_f64, data.input_int, data.input_fraction,
                output_f64, output_parts, data.expected))
    }
}