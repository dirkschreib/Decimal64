# Comparison of decimal floatingpoint types in Swift

This is a small project which compares two different implementation for a Swift `Decimal64` struct against the builtin types Double and Decimal.

## DecimalFP64

This is a struct which conforms to the FloatingPoint protocol. (It compiles fine but not all functions are implemented)
It tries to follow IEEE 754 as closely as possible and supports +/- Infinity, signed zeros and NaNs.

Internal structure:

Part | Bits | Comment 
-|-|-
Sign | 63          | separate bit
Exponent | 54..62  | with room for NaN and Inf
Significand | 0..53| 16 decimal digits


## Decimal64

This struct doesn't conform to the FloatingPoint protocoll and uses a different internal representation of the numbers.
It has no support for +/- Infinity, uses a 2's complement for negative numbers (i.e. no signed zeros) and ignores NaNs.

Internal structure:

Part | Bits | Comment
-|-|-
Significand | 9..63 | 16 decimal digits and sign
Exponent | 0..8 | 

## Decimal (builtin, for reference)

This is an Apple provided struct with 160bit. Does not conform to the FloatingPoint protocol.

## Double (builtin, for reference)

Internal floatingpoint type with 64bit.

# Performance

To test the performance of a few basic operations (+,*,/ and conversion to string)
a small benchmark was used to compare the four different types.

As Double and DecimalFP64 both conformed to the FloatingPoint protocol, these were tested with a generic version too.

Testing was concluded with Xcode 10.2.1 on an iMac (Retina 5K, 27", 2017) with 4.2 GHz Intel Core i7 and macOS Mojave 10.14.5

Number Type           | Debug  | Release | relative to Debug
-|-|-
Double                | 0.100s | 0.094s |  -5%
Decimal               | 0.427s | 0.417s |  -2%
DecimalFP64           | 0.784s | 0.101s | -87%
Decimal64             | 0.543s | 0.102s | -81%
Double (generic)      | 0.137s | 0.124s |  -8%
DecimalFP64 (generic) | 0.850s | 0.151s | -82%

The debug performance didn't look very promising, but llvm can optimize this code very well.

Key findings:
- The difference between the two new implementations is negligible.
- There is a very bad performance penalty if someone tries to use numbers in a generic way.
  (i.e. protocol witness overhead)
- The own implementation is just 5% slower than the builtin Double (which is unsuitable for most currency calculations)



