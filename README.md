# Comparison of decimal floating-point types in Swift

This is a small project which compares two different implementations for a Swift `Decimal64` struct against the builtin types Double and Decimal.

## DecimalFP64 (deprecated)

This is a struct which conforms to the `FloatingPoint` protocol. (It compiles fine but not all functions are implemented)
It tries to follow IEEE 754 as closely as possible and supports +/- Infinity, signed zeros and NaNs.

Internal structure:

Part | Bits | Comment 
-|-|-
Sign | 63          | separate bit
Exponent | 54..62  | with room for NaN and Inf
Significand | 0..53| 16 decimal digits


## Decimal64

This struct doesn't conform to the `FloatingPoint` protocol and uses a different internal representation of the numbers.
It has no support for +/- Infinity, uses a 2's complement for negative numbers (i.e. no signed zeros) and ignores NaNs.

Internal structure:

Part | Bits | Comment
-|-|-
Significand | 9..63 | 16 decimal digits and sign
Exponent | 0..8 | 

## Decimal (builtin, for reference)

This is an Apple provided struct with 160bit. Does not conform to the `FloatingPoint` protocol.

## Double (builtin, for reference)

Internal floating-point type with 64bit.

# Performance

To test the performance of a few basic operations (+,*,/ and conversion to string)
a small benchmark was used to compare the four different types.

As `Double` and `DecimalFP64` both conformed to the `FloatingPoint` protocol, these were tested with a generic version too.

Testing was concluded with Xcode 10.2.1 on an iMac (Retina 5K, 27", 2017) with 4.2 GHz Intel Core i7 and macOS Mojave 10.14.5

**Update** for version v1.1: `Decimal64` and `DecimalFP64` now conform to the `TextOutputStreamable` protocol.

Number Type                  | Debug  | Release | rel.  | Debug v1.1 | Release v1.1 | rel. 
-|-|-|-|-|-|-
`Decimal`                          | 0.427s | 0.417s |  -2%   | 0.427s | 0.417s | -3%
`Decimal64`                      |  0.543s | 0.102s | -81% | 0.521s | 0.078s | -85%
`DecimalFP64`                  | 0.784s | 0.101s | -87%  | 0.481s | 0.079s | -84%
`DecimalFP64` (generic)   | 0.850s | 0.151s | -82%  | 0.529s | 0.110s | -79%
`Double`                            | 0.100s | 0.094s |  -5%  | 0.102s | 0.095s | -9%
`Double` (generic)             | 0.137s | 0.124s |  -8%   | 0.137s | 0.125s | -10%

Key findings v1.0:
- The debug performance didn't look very promising, but llvm can optimize this code very well.
- The difference between the two new implementations is negligible.
- There is a very bad performance penalty if someone tries to use numbers in a generic way.
  (i.e. protocol witness overhead)
  **Update**
  After discussion on https://forums.swift.org/t/performance-overhead-for-protocols/27104 Joe Groff opened https://bugs.swift.org/browse/SR-11158 (i.e. rdar://problem/53285593)
- The own implementation is just 5% slower than the builtin `Double` (which is unsuitable for most currency calculations)

Key findings v1.1:
- I have never heard of `TextOutputStreamable` before. (Thanks Brent!) This is a tremendous performance benefit.
- `DecimalFP64` and `Decimal64` are now faster than `Double`. They need 18% less time to complete the benchmark test.
- The performance difference to `Decimal` is even higher: The benchmark test is completed in 1/5th of the time.

# Performance Update for Apple M1 Chip

I've done some more testing with my new MacBook Air M1 (8GPU, 16GB, 512GB). All test with Big Sur (11.0.1) (exception MacBook Air with 1.6GHz i5 is on 11.1) and Xcode 12.2.

Number Type                  | MBA x86 Deb | MBA x86 Rel | iMac x86 Deb | iMac x86 Rel | MBA M1 Deb | MBA M1 Rel 
-|-|-|-|-|-|-
`Decimal`                    |  7.308s |  6.635s |  5.535s | 4.795s |  4.121s | 3.737s
`Decimal64`                  | 34.237s |  1.578s | 25.237s | 1.212s | 16.965s | 0.890s
`DecimalFP64`                | 23.192s |  1.594s | 15.753s | 1.217s | 10.476s | 0.911s
`DecimalFP64` (generic)      | 23.139s |  2.261s | 16.467s | 1.713s | 11.005s | 1.226s
`Double`                     |  2.567s |  1.640s |  1.697s | 1.193s |  1.227s | 0.885s
`Double` (generic)           |  3.521s |  2.256s |  2.273s | 1.684s |  1.589s | 1.203s

