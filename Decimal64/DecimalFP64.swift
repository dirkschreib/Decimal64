//
//  DecimalFP64.swift
//  Decimal64
//
//  Created by Dirk on 18.07.19.
//  Copyright © 2019 Dirk Schreib. All rights reserved.
//

import Foundation

/// Constants TenPow<x> = 10^X
let TenPow0: Int64  =                         1
let TenPow1: Int64  =                        10
let TenPow2: Int64  =                       100
let TenPow3: Int64  =                     1_000
let TenPow4: Int64  =                    10_000
let TenPow5: Int64  =                   100_000
let TenPow6: Int64  =                 1_000_000
let TenPow7: Int64  =                10_000_000
let TenPow8: Int64  =               100_000_000
let TenPow9: Int64  =             1_000_000_000
let TenPow10: Int64 =            10_000_000_000
let TenPow11: Int64 =           100_000_000_000
let TenPow12: Int64 =         1_000_000_000_000
let TenPow13: Int64 =        10_000_000_000_000
let TenPow14: Int64 =       100_000_000_000_000
let TenPow15: Int64 =     1_000_000_000_000_000
let TenPow16: Int64 =    10_000_000_000_000_000
let TenPow17: Int64 =   100_000_000_000_000_000
let TenPow18: Int64 = 1_000_000_000_000_000_000

/// For faster access to power of tens
let PowerOf10: [Int64] =
    [
        TenPow0,
        TenPow1,
        TenPow2,
        TenPow3,
        TenPow4,
        TenPow5,
        TenPow6,
        TenPow7,
        TenPow8,
        TenPow9,
        TenPow10,
        TenPow11,
        TenPow12,
        TenPow13,
        TenPow14,
        TenPow15,
        TenPow16,
        TenPow17,
        TenPow18
]

/// This methods calculate num * 10^shift.
///
/// - Parameters:
///   - num: The number to process, must not have more than 18 digits.
///   - shift: Number of decimal digits to shift, must not be larger than +16.
func shiftDigits( _ num: inout Int64, _ shift: Int )
{
    if  shift < -17 {
        num = 0
    }
    else if shift < 0 {
        num /= PowerOf10[ -shift ]
    }
    else {
        num *= PowerOf10[ shift ]
    }
}

/// Internal helper function to shift a number to the left
/// until it fills 16 digits.
///
/// - Parameters:  numIn       The number to process, must not
///                     have more than 18 digits.
///
/// - Returns: number of shifted digits.
func int64_shiftLeftTo16( _ num: inout Int64 ) -> Int
{
    var ret = 0

    if num < TenPow8 {
        if num < TenPow4 {
            ret = 12
            num *= TenPow12
        }
        else {
            ret = 8
            num *= TenPow8
        }
    }
    else {
        if num < TenPow12 {
            ret = 4
            num *= TenPow4
        }
    }

    if num < TenPow15 {
        if num < TenPow13 {
            ret += 3
            num *= 1000
        }
        else if num < TenPow14 {
            ret += 2
            num *= 100
        }
        else {
            ret += 1
            num *= 10
        }
    }

    return ret
}


/// Internal helper function to shift a number to the left
/// until it fills 18 digits.
///
/// - Parameter num: The number to process, must not have more than 18 digits.
/// - Returns: number of shifted digits.
func int64_shiftLeftTo18( _ num: inout Int64 ) -> Int
{
    var ret = 0

    if num < TenPow8 {
        if num < TenPow4 {
            ret = 14
            num *= TenPow14
        }
        else {
            ret = 10
            num *= TenPow10
        }
    }
    else {
        if num < TenPow12 {
            ret = 6
            num *= TenPow6
        }
        else if ( num < TenPow16 ) {
            ret = 2
            num *= 100
        }
    }

    if num < TenPow17 {
        if num < TenPow15 {
            ret += 3
            num *= 1000
        }
        else if num < TenPow16 {
            ret += 2
            num *= 100
        }
        else {
            ret += 1
            num *= 10
        }
    }

    return ret
}

/// Internal helper function to shift a number to the left until
/// it fills 17 digits or number of shifted digits reaches limit.
/// (whatever comes first)
///
/// - Parameters:
///   - num: The number to process, must not have more than 18 digits
///   - limit: Maximum number of decimal digits to shift, must not be larger than 17
/// - Returns: count of shifted digits
func int64_shiftLeftTo17orLim( _ num: inout Int64, _ limit: Int ) -> Int
{
    if num < PowerOf10[ 17 - limit ] {
        // num will not overflow if pushed left
        num *= PowerOf10[ limit ]

        return limit
    }

    var ret = 0

    // num will overflow if pushed left, just shift to 17 digits
    if num < TenPow8 {
        if num < TenPow4 {
            ret = 13
            num *= TenPow13
        }
        else {
            ret = 9
            num *= TenPow9
        }
    }
    else {
        if num < TenPow12 {
            ret = 5
            num *= TenPow5
        }
        else if num < TenPow16 {
            ret = 1
            num *= 10
        }
    }

    if num < TenPow16 {
        if num < TenPow14 {
            ret += 3
            num *= 1000
        }
        else if num < TenPow15 {
            ret += 2
            num *= 100
        }
        else {
            ret += 1
            num *= 10
        }
    }

    return ret
}

/// Internal helper function to shift a number to the left until
/// it fills 17 digits or number of shifted digits reaches 16.
/// (whatever comes first)
/// Same as int64_shiftLeftTo17_16( in, 16 ) but faster.
///
/// - Parameters:  numIn       The number to process, must not have
///                     more than 18 digits.
///
/// - Returns: number of shifted digits.
func int64_shiftLeftTo17_16( _ num: inout Int64 ) -> Int
{
    var ret = 0

    if num < TenPow8 {
        if num < TenPow4 {
            ret = 13
            num *= TenPow13
        }
        else {
            ret = 9
            num *= TenPow9
        }
    }
    else
    {
        if num < TenPow12 {
            ret = 5
            num *= TenPow5
        }
        else if num < TenPow16 {
            ret = 1
            num *= 10
        }
    }

    if num < TenPow16 {
        if num < TenPow14 {
            ret += 3
            num *= 1000
        }
        else if num < TenPow15 {
            ret += 2
            num *= 100
        }
        else {
            ret += 1
            num *= 10
        }
    }

    return ret
}


/// Internal helper function to shift a number to the left until
/// it fills 17 digits or number of shifted digits reaches 8.
/// (whatever comes first)
/// Same as int64_shiftLeftTo17_16( in, 8 ) but faster.
///
/// - Parameters:  numIn       The number to process, must not have
///                     more than 18 digits.
///
/// - Returns: number of shifted digits.
func int64_shiftLeftTo17_8( _ num: inout Int64 ) -> Int
{
    var ret = 0

    if num < TenPow8 {
        ret = 8
        num *= TenPow8
    }
    else {
        if num < TenPow12 {
            ret = 5
            num *= TenPow5
        }
        else if num < TenPow16 {
            ret = 1
            num *= 10
        }

        if num < TenPow16 {
            if num < TenPow14 {
                ret += 3
                num *= 1000
            }
            else if num < TenPow15 {
                ret += 2
                num *= 100
            }
            else {
                ret += 1
                num *= 10
            }
        }
    }

    return ret
}


///////////////////////////////////////////////////////////////
/// Struct to represent decimal floating point 64 bit numbers.
///
/// This class represents floating point numbers having a 54
/// bit coefficient, a sign bit and a 9 bit exponent.
/// The coefficient range from bit 0 to 53, the sign bit is
/// bit 54 and the exponent range from bit 55 to 63.
/// The accuracy of this representation is 16 decimal digits.
///
/// It was designed after ideas from C++ code modelled after
/// the "General Decimal Arithmetic Specification"
/// Version 1.11 from 2003-02-21
/// http://www2.hursley.ibm.com/decimal/decarith.pdf
/// which has moved to a new site:
/// http://speleotrove.com/decimal/decarith.pdf
struct DecimalFP64: FloatingPoint
{
    typealias Magnitude = DecimalFP64
    var magnitude: Magnitude { return DecimalFP64.abs(self) }

    init<Source>(_ value: Source) where Source : BinaryInteger {
        fatalError()
    }

    init?<Source>(exactly value: Source) where Source : BinaryInteger {
        fatalError()
    }


    /// A type that represents any written exponent.
    typealias Exponent = Int

    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - sign: The sign to use for the new value.
    ///   - exponent: The new value's exponent.
    ///   - significand: The new value's significand.
    public init(sign: FloatingPointSign, exponent: DecimalFP64.Exponent, significand: DecimalFP64) {
        setComponents(significand.getMantissa(), exponent + significand.getExponent(), sign == .minus )
    }

    /// This initializer implements the IEEE 754 `copysign` operation.
    ///
    /// - Parameters:
    ///   - signOf: A value from which to use the sign. The result of the
    ///     initializer has the same sign as `signOf`.
    ///   - magnitudeOf: A value from which to use the magnitude. The result of
    ///     the initializer has the same magnitude as `magnitudeOf`.
    public init(signOf: DecimalFP64, magnitudeOf: DecimalFP64) {
        setComponents(magnitudeOf.getMantissa(), magnitudeOf.getExponent(), signOf.getSign())
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: UInt8) {
        self.init( value, 0)
    }
    public init(_ value: UInt8, _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: Int8) {
        self.init( value, 0 )
    }
    public init(_ value: Int8 , _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: UInt16) {
        self.init( value, 0 )
    }
    public init(_ value: UInt16, _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: Int16) {
        self.init(value, 0)
    }
    public init(_ value: Int16, _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: UInt32) {
        self.init(value, 0)
    }
    public init(_ value: UInt32, _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: Int32) {
        self.init(value, 0)
    }
    public init(_ value: Int32, _ exponent: DecimalFP64.Exponent = 0 ) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: UInt64) {
        self.init(value, 0)
    }
    public init( _ mantissa: UInt64, _ exponent: Int = 0, _ negative: Bool = false) {
        setComponents( Int64(mantissa), exponent, negative ) // will overflow if greater >Int64.max
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: Int64) {
        self.init(value, 0)
    }
    public init( _ mantissa: Int64, _ exponent: Int = 0, _ negative: Bool = false) {
        setComponents( mantissa, exponent, negative )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: UInt) {
        self.init(value, 0)
    }
    public init(_ value: UInt, _ exponent: DecimalFP64.Exponent = 0) {
        self.init( Int64(value), exponent )
    }

    /// Creates a new value, rounded to the closest possible representation.
    ///
    /// If two representable values are equally close, the result is the value
    /// with more trailing zeros in its significand bit pattern.
    ///
    /// - Parameter value: The integer to convert to a floating-point value.
    public init(_ value: Int) {
        self.init(value, 0)
    }
    public init(_ value: Int, _ exponent: DecimalFP64.Exponent = 0) {
        self.init( Int64(value), exponent )
    }

    /// The radix, or base of exponentiation, for a floating-point type.
    ///
    /// The magnitude of a floating-point value `x` of type `F` can be calculated
    /// by using the following formula, where `**` is exponentiation:
    ///
    ///     let magnitude = x.significand * F.radix ** x.exponent
    ///
    /// A conforming type may use any integer radix, but values other than 2 (for
    /// binary floating-point types) or 10 (for decimal floating-point types)
    /// are extraordinarily rare in practice.
    public static var radix: Int { return 10 }

    /// A quiet NaN ("not a number").
    ///
    /// A NaN compares not equal, not greater than, and not less than every
    /// value, including itself. Passing a NaN to an operation generally results
    /// in NaN.
    ///
    ///     let x = 1.21
    ///     // x > Double.nan == false
    ///     // x < Double.nan == false
    ///     // x == Double.nan == false
    ///
    /// Because a NaN always compares not equal to itself, to test whether a
    /// floating-point value is NaN, use its `isNaN` property instead of the
    /// equal-to operator (`==`). In the following example, `y` is NaN.
    ///
    ///     let y = x + Double.nan
    ///     print(y == Double.nan)
    ///     // Prints "false"
    ///     print(y.isNaN)
    ///     // Prints "true"
    ///
    /// - SeeAlso: `isNaN`, `signalingNaN`
    public static var nan: DecimalFP64 {
        var this: DecimalFP64 = 0
        this.setNaN()
        return this
    }

    /// A signaling NaN ("not a number").
    ///
    /// The default IEEE 754 behavior of operations involving a signaling NaN is
    /// to raise the Invalid flag in the floating-point environment and return a
    /// quiet NaN.
    ///
    /// Operations on types conforming to the `FloatingPoint` protocol should
    /// support this behavior, but they might also support other options. For
    /// example, it would be reasonable to implement alternative operations in
    /// which operating on a signaling NaN triggers a runtime error or results
    /// in a diagnostic for debugging purposes. Types that implement alternative
    /// behaviors for a signaling NaN must document the departure.
    ///
    /// Other than these signaling operations, a signaling NaN behaves in the
    /// same manner as a quiet NaN.
    ///
    /// - SeeAlso: `nan`
    public static var signalingNaN: DecimalFP64 {
        //TODO: what?
        return DecimalFP64.nan
    }

    /// Positive infinity.
    ///
    /// Infinity compares greater than all finite numbers and equal to other
    /// infinite values.
    ///
    ///     let x = Double.greatestFiniteMagnitude
    ///     let y = x * 2
    ///     // y == Double.infinity
    ///     // y > x
    public static var infinity: DecimalFP64 {
        var this: DecimalFP64 = 0
        this.setInfinity()
        return this
    }

    /// The greatest finite number representable by this type.
    ///
    /// This value compares greater than or equal to all finite numbers, but less
    /// than `infinity`.
    ///
    /// This value corresponds to type-specific C macros such as `FLT_MAX` and
    /// `DBL_MAX`. The naming of those macros is slightly misleading, because
    /// `infinity` is greater than this value.
    public static var greatestFiniteMagnitude: DecimalFP64 {
        return DecimalFP64(Int64(9_999_999_999_999_999), 255, false ) //TODO: Check Exponent
    }

    /// The mathematical constant pi.
    ///
    /// This value should be rounded toward zero to keep user computations with
    /// angles from inadvertently ending up in the wrong quadrant. A type that
    /// conforms to the `FloatingPoint` protocol provides the value for `pi` at
    /// its best possible precision.
    ///
    ///     print(Double.pi)
    ///     // Prints "3.14159265358979"
    public static var pi: DecimalFP64 {
        return DecimalFP64( Double.pi )
    }

    /// The unit in the last place of this value.
    ///
    /// This is the unit of the least significant digit in this value's
    /// significand. For most numbers `x`, this is the difference between `x`
    /// and the next greater (in magnitude) representable number. There are some
    /// edge cases to be aware of:
    ///
    /// - If `x` is not a finite number, then `x.ulp` is NaN.
    /// - If `x` is very small in magnitude, then `x.ulp` may be a subnormal
    ///   number. If a type does not support subnormals, `x.ulp` may be rounded
    ///   to zero.
    /// - `greatestFiniteMagnitude.ulp` is a finite number, even though the next
    ///   greater representable value is `infinity`.
    ///
    /// This quantity, or a related quantity, is sometimes called *epsilon* or
    /// *machine epsilon.* Avoid that name because it has different meanings in
    /// different languages, which can lead to confusion, and because it
    /// suggests that it is a good tolerance to use for comparisons, which it
    /// almost never is.
    public var ulp: DecimalFP64 {
        var this = self
        this.setComponents(1, this.getExponent(), this.getSign() ) //TODO: Check if correct don't know if normalization is necessary
        return this
    }

    /// The unit in the last place of 1.0.
    ///
    /// The positive difference between 1.0 and the next greater representable
    /// number. The `ulpOfOne` constant corresponds to the C macros
    /// `FLT_EPSILON`, `DBL_EPSILON`, and others with a similar purpose.
    public static var ulpOfOne: DecimalFP64 {
        return DecimalFP64( 1.000000000000001 ) - DecimalFP64( 1 )
    }

    /// The least positive normal number.
    ///
    /// This value compares less than or equal to all positive normal numbers.
    /// There may be smaller positive numbers, but they are *subnormal*, meaning
    /// that they are represented with less precision than normal numbers.
    ///
    /// This value corresponds to type-specific C macros such as `FLT_MIN` and
    /// `DBL_MIN`. The naming of those macros is slightly misleading, because
    /// subnormals, zeros, and negative numbers are smaller than this value.
    public static var leastNormalMagnitude: DecimalFP64 {
        return DecimalFP64(Int64(1_000_000_000_000_000), -256, false ) //TODO: Check exponent
    }

    /// The least positive number.
    ///
    /// This value compares less than or equal to all positive numbers, but
    /// greater than zero. If the type supports subnormal values,
    /// `leastNonzeroMagnitude` is smaller than `leastNormalMagnitude`;
    /// otherwise they are equal.
    public static var leastNonzeroMagnitude: DecimalFP64 {
        return DecimalFP64(Int64(1), -256, false ) //TODO: Check exponent
    }

    /// The sign of the floating-point value.
    ///
    /// The `sign` property is `.minus` if the value's signbit is set, and
    /// `.plus` otherwise. For example:
    ///
    ///     let x = -33.375
    ///     // x.sign == .minus
    ///
    /// Do not use this property to check whether a floating point value is
    /// negative. For a value `x`, the comparison `x.sign == .minus` is not
    /// necessarily the same as `x < 0`. In particular, `x.sign == .minus` if
    /// `x` is -0, and while `x < 0` is always `false` if `x` is NaN, `x.sign`
    /// could be either `.plus` or `.minus`.
    public var sign: FloatingPointSign {
        if getSign() {
            return .minus
        } else {
            return .plus
        }
    }

    /// The exponent of the floating-point value.
    ///
    /// The *exponent* of a floating-point value is the integer part of the
    /// logarithm of the value's magnitude. For a value `x` of a floating-point
    /// type `F`, the magnitude can be calculated as the following, where `**`
    /// is exponentiation:
    ///
    ///     let magnitude = x.significand * F.radix ** x.exponent
    ///
    /// In the next example, `y` has a value of `21.5`, which is encoded as
    /// `1.34375 * 2 ** 4`. The significand of `y` is therefore 1.34375.
    ///
    ///     let y: Double = 21.5
    ///     // y.significand == 1.34375
    ///     // y.exponent == 4
    ///     // Double.radix == 2
    ///
    /// The `exponent` property has the following edge cases:
    ///
    /// - If `x` is zero, then `x.exponent` is `Int.min`.
    /// - If `x` is +/-infinity or NaN, then `x.exponent` is `Int.max`
    ///
    /// This property implements the `logB` operation defined by the [IEEE 754
    /// specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    public var exponent: DecimalFP64.Exponent {
        return getExponent()
    }

    /// The significand of the floating-point value.
    ///
    /// The magnitude of a floating-point value `x` of type `F` can be calculated
    /// by using the following formula, where `**` is exponentiation:
    ///
    ///     let magnitude = x.significand * F.radix ** x.exponent
    ///
    /// In the next example, `y` has a value of `21.5`, which is encoded as
    /// `1.34375 * 2 ** 4`. The significand of `y` is therefore 1.34375.
    ///
    ///     let y: Double = 21.5
    ///     // y.significand == 1.34375
    ///     // y.exponent == 4
    ///     // Double.radix == 2
    ///
    /// If a type's radix is 2, then for finite nonzero numbers, the significand
    /// is in the range `1.0 ..< 2.0`. For other values of `x`, `x.significand`
    /// is defined as follows:
    ///
    /// - If `x` is zero, then `x.significand` is 0.0.
    /// - If `x` is infinity, then `x.significand` is 1.0.
    /// - If `x` is NaN, then `x.significand` is NaN.
    /// - Note: The significand is frequently also called the *mantissa*, but
    ///   significand is the preferred terminology in the [IEEE 754
    ///   specification][spec], to allay confusion with the use of mantissa for
    ///   the fractional part of a logarithm.
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    public var significand: DecimalFP64 {
        return DecimalFP64( getMantissa() )
    }

    /// Returns the sum of this value and the given value, rounded to a
    /// representable value.
    ///
    /// This method serves as the basis for the addition operator (`+`). For
    /// example:
    ///
    ///     let x = 1.5
    ///     print(x.adding(2.25))
    ///     // Prints "3.75"
    ///     print(x + 2.25)
    ///     // Prints "3.75"
    ///
    /// The `adding(_:)` method implements the addition operation defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to add.
    /// - Returns: The sum of this value and `other`, rounded to a representable
    ///   value.
    ///
    /// - SeeAlso: `add(_:)`
    public func adding(_ other: DecimalFP64) -> DecimalFP64 {
        var left = self
        left += other
        return left
    }

    /// Adds the given value to this value in place, rounded to a representable
    /// value.
    ///
    /// This method serves as the basis for the in-place addition operator
    /// (`+=`). For example:
    ///
    ///     var (x, y) = (2.25, 2.25)
    ///     x.add(7.0)
    ///     // x == 9.25
    ///     y += 7.0
    ///     // y == 9.25
    ///
    /// - Parameter other: The value to add.
    ///
    /// - SeeAlso: `adding(_:)`
    public mutating func add(_ other: DecimalFP64) {
        self += other
    }

    /// Returns the additive inverse of this value.
    ///
    /// The result is always exact. This method serves as the basis for the
    /// negation operator (prefixed `-`). For example:
    ///
    ///     let x = 21.5
    ///     let y = x.negated()
    ///     // y == -21.5
    ///
    /// - Returns: The additive inverse of this value.
    ///
    /// - SeeAlso: `negate()`
    public func negated() -> DecimalFP64 {
        var left = self
        left.negate()
        return left
    }

    /// Replaces this value with its additive inverse.
    ///
    /// The result is always exact. This example uses the `negate()` method to
    /// negate the value of the variable `x`:
    ///
    ///     var x = 21.5
    ///     x.negate()
    ///     // x == -21.5
    ///
    /// - SeeAlso: `negated()`
    public mutating func negate() {
        Data ^= DecimalFP64.SIG_MASK
    }

    /// Returns the difference of this value and the given value, rounded to a
    /// representable value.
    ///
    /// This method serves as the basis for the subtraction operator (`-`). For
    /// example:
    ///
    ///     let x = 7.5
    ///     print(x.subtracting(2.25))
    ///     // Prints "5.25"
    ///     print(x - 2.25)
    ///     // Prints "5.25"
    ///
    /// The `subtracting(_:)` method implements the subtraction operation
    /// defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to subtract from this value.
    /// - Returns: The difference of this value and `other`, rounded to a
    ///   representable value.
    ///
    /// - SeeAlso: `subtract(_:)`
    public func subtracting(_ other: DecimalFP64) -> DecimalFP64 {
        var left = self
        left -= other
        return left
    }

    /// Subtracts the given value from this value in place, rounding to a
    /// representable value.
    ///
    /// This method serves as the basis for the in-place subtraction operator
    /// (`-=`). For example:
    ///
    ///     var (x, y) = (7.5, 7.5)
    ///     x.subtract(2.25)
    ///     // x == 5.25
    ///     y -= 2.25
    ///     // y == 5.25
    ///
    /// - Parameter other: The value to subtract.
    ///
    /// - SeeAlso: `subtracting(_:)`
    public mutating func subtract(_ other: DecimalFP64) {
        self -= other
    }

    /// Returns the product of this value and the given value, rounded to a
    /// representable value.
    ///
    /// This method serves as the basis for the multiplication operator (`*`).
    /// For example:
    ///
    ///     let x = 7.5
    ///     print(x.multiplied(by: 2.25))
    ///     // Prints "16.875"
    ///     print(x * 2.25)
    ///     // Prints "16.875"
    ///
    /// The `multiplied(by:)` method implements the multiplication operation
    /// defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to multiply by this value.
    /// - Returns: The product of this value and `other`, rounded to a
    ///   representable value.
    ///
    /// - SeeAlso: `multiply(by:)`
    public func multiplied(by other: DecimalFP64) -> DecimalFP64 {
        var left = self
        left *= other
        return left
    }

    /// Multiplies this value by the given value in place, rounding to a
    /// representable value.
    ///
    /// This method serves as the basis for the in-place multiplication operator
    /// (`*=`). For example:
    ///
    ///     var (x, y) = (7.5, 7.5)
    ///     x.multiply(by: 2.25)
    ///     // x == 16.875
    ///     y *= 2.25
    ///     // y == 16.875
    ///
    /// - Parameter other: The value to multiply by this value.
    ///
    /// - SeeAlso: `multiplied(by:)`
    public mutating func multiply(by other: DecimalFP64) {
        self *= other
    }

    /// Returns the quotient of this value and the given value, rounded to a
    /// representable value.
    ///
    /// This method serves as the basis for the division operator (`/`). For
    /// example:
    ///
    ///     let x = 7.5
    ///     let y = x.divided(by: 2.25)
    ///     // y == 16.875
    ///     let z = x * 2.25
    ///     // z == 16.875
    ///
    /// The `divided(by:)` method implements the division operation
    /// defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to use when dividing this value.
    /// - Returns: The quotient of this value and `other`, rounded to a
    ///   representable value.
    ///
    /// - SeeAlso: `divide(by:)`
    public func divided(by other: DecimalFP64) -> DecimalFP64 {
        var left = self
        left /= other
        return left
    }

    /// Divides this value by the given value in place, rounding to a
    /// representable value.
    ///
    /// This method serves as the basis for the in-place division operator
    /// (`/=`). For example:
    ///
    ///     var (x, y) = (16.875, 16.875)
    ///     x.divide(by: 2.25)
    ///     // x == 7.5
    ///     y /= 2.25
    ///     // y == 7.5
    ///
    /// - Parameter other: The value to use when dividing this value.
    ///
    /// - SeeAlso: `divided(by:)`
    public mutating func divide(by other: DecimalFP64) {
        self /= other
    }

    /// Returns the remainder of this value divided by the given value.
    ///
    /// For two finite values `x` and `y`, the remainder `r` of dividing `x` by
    /// `y` satisfies `x == y * q + r`, where `q` is the integer nearest to
    /// `x / y`. If `x / y` is exactly halfway between two integers, `q` is
    /// chosen to be even. Note that `q` is *not* `x / y` computed in
    /// floating-point arithmetic, and that `q` may not be representable in any
    /// available integer type.
    ///
    /// The following example calculates the remainder of dividing 8.625 by 0.75:
    ///
    ///     let x = 8.625
    ///     print(x / 0.75)
    ///     // Prints "11.5"
    ///
    ///     let q = (x / 0.75).rounded(.toNearestOrEven)
    ///     // q == 12.0
    ///     let r = x.remainder(dividingBy: 0.75)
    ///     // r == -0.375
    ///
    ///     let x1 = 0.75 * q + r
    ///     // x1 == 8.625
    ///
    /// If this value and `other` are finite numbers, the remainder is in the
    /// closed range `-abs(other / 2)...abs(other / 2)`. The
    /// `remainder(dividingBy:)` method is always exact. This method implements
    /// the remainder operation defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to use when dividing this value.
    /// - Returns: The remainder of this value divided by `other`.
    ///
    /// - SeeAlso: `formRemainder(dividingBy:)`,
    ///   `truncatingRemainder(dividingBy:)`
    public func remainder(dividingBy other: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return self
    }

    /// Replaces this value with the remainder of itself divided by the given
    /// value.
    ///
    /// For two finite values `x` and `y`, the remainder `r` of dividing `x` by
    /// `y` satisfies `x == y * q + r`, where `q` is the integer nearest to
    /// `x / y`. If `x / y` is exactly halfway between two integers, `q` is
    /// chosen to be even. Note that `q` is *not* `x / y` computed in
    /// floating-point arithmetic, and that `q` may not be representable in any
    /// available integer type.
    ///
    /// The following example calculates the remainder of dividing 8.625 by 0.75:
    ///
    ///     var x = 8.625
    ///     print(x / 0.75)
    ///     // Prints "11.5"
    ///
    ///     let q = (x / 0.75).rounded(.toNearestOrEven)
    ///     // q == 12.0
    ///     x.formRemainder(dividingBy: 0.75)
    ///     // x == -0.375
    ///
    ///     let x1 = 0.75 * q + x
    ///     // x1 == 8.625
    ///
    /// If this value and `other` are finite numbers, the remainder is in the
    /// closed range `-abs(other / 2)...abs(other / 2)`. The
    /// `remainder(dividingBy:)` method is always exact.
    ///
    /// - Parameter other: The value to use when dividing this value.
    ///
    /// - SeeAlso: `remainder(dividingBy:)`,
    ///   `formTruncatingRemainder(dividingBy:)`
    public mutating func formRemainder(dividingBy other: DecimalFP64) {
        assertionFailure("not implemented yet")
    }

    /// Returns the remainder of this value divided by the given value using
    /// truncating division.
    ///
    /// Performing truncating division with floating-point values results in a
    /// truncated integer quotient and a remainder. For values `x` and `y` and
    /// their truncated integer quotient `q`, the remainder `r` satisfies
    /// `x == y * q + r`.
    ///
    /// The following example calculates the truncating remainder of dividing
    /// 8.625 by 0.75:
    ///
    ///     let x = 8.625
    ///     print(x / 0.75)
    ///     // Prints "11.5"
    ///
    ///     let q = (x / 0.75).rounded(.towardZero)
    ///     // q == 11.0
    ///     let r = x.truncatingRemainder(dividingBy: 0.75)
    ///     // r == 0.375
    ///
    ///     let x1 = 0.75 * q + r
    ///     // x1 == 8.625
    ///
    /// If this value and `other` are both finite numbers, the truncating
    /// remainder has the same sign as this value and is strictly smaller in
    /// magnitude than `other`. The `truncatingRemainder(dividingBy:)` method
    /// is always exact.
    ///
    /// - Parameter other: The value to use when dividing this value.
    /// - Returns: The remainder of this value divided by `other` using
    ///   truncating division.
    ///
    /// - SeeAlso: `formTruncatingRemainder(dividingBy:)`,
    ///   `remainder(dividingBy:)`
    public func truncatingRemainder(dividingBy other: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return self
    }

    /// Replaces this value with the remainder of itself divided by the given
    /// value using truncating division.
    ///
    /// Performing truncating division with floating-point values results in a
    /// truncated integer quotient and a remainder. For values `x` and `y` and
    /// their truncated integer quotient `q`, the remainder `r` satisfies
    /// `x == y * q + r`.
    ///
    /// The following example calculates the truncating remainder of dividing
    /// 8.625 by 0.75:
    ///
    ///     var x = 8.625
    ///     print(x / 0.75)
    ///     // Prints "11.5"
    ///
    ///     let q = (x / 0.75).rounded(.towardZero)
    ///     // q == 11.0
    ///     x.formTruncatingRemainder(dividingBy: 0.75)
    ///     // x == 0.375
    ///
    ///     let x1 = 0.75 * q + x
    ///     // x1 == 8.625
    ///
    /// If this value and `other` are both finite numbers, the truncating
    /// remainder has the same sign as this value and is strictly smaller in
    /// magnitude than `other`. The `formTruncatingRemainder(dividingBy:)`
    /// method is always exact.
    ///
    /// - Parameter other: The value to use when dividing this value.
    ///
    /// - SeeAlso: `truncatingRemainder(dividingBy:)`,
    ///   `formRemainder(dividingBy:)`
    public mutating func formTruncatingRemainder(dividingBy other: DecimalFP64) {
        assertionFailure("not implemented yet")
    }

    /// Returns the square root of the value, rounded to a representable value.
    ///
    /// The following example declares a function that calculates the length of
    /// the hypotenuse of a right triangle given its two perpendicular sides.
    ///
    ///     func hypotenuse(_ a: Double, _ b: Double) -> Double {
    ///         return (a * a + b * b).squareRoot()
    ///     }
    ///
    ///     let (dx, dy) = (3.0, 4.0)
    ///     let distance = hypotenuse(dx, dy)
    ///     // distance == 5.0
    ///
    /// - Returns: The square root of the value.
    ///
    /// - SeeAlso: `sqrt(_:)`, `formSquareRoot()`
    public func squareRoot() -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return self
    }

    /// Replaces this value with its square root, rounded to a representable
    /// value.
    ///
    /// - SeeAlso: `sqrt(_:)`, `squareRoot()`
    public mutating func formSquareRoot() {
        assertionFailure("not implemented yet")
    }

    /// Returns the result of adding the product of the two given values to this
    /// value, computed without intermediate rounding.
    ///
    /// This method is equivalent to the C `fma` function and implements the
    /// `fusedMultiplyAdd` operation defined by the [IEEE 754
    /// specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - lhs: One of the values to multiply before adding to this value.
    ///   - rhs: The other value to multiply.
    /// - Returns: The product of `lhs` and `rhs`, added to this value.
    public func addingProduct(_ lhs: DecimalFP64, _ rhs: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return self
    }

    /// Adds the product of the two given values to this value in place, computed
    /// without intermediate rounding.
    ///
    /// - Parameters:
    ///   - lhs: One of the values to multiply before adding to this value.
    ///   - rhs: The other value to multiply.
    public mutating func addProduct(_ lhs: DecimalFP64, _ rhs: DecimalFP64) {
        assertionFailure("not implemented yet")
    }

    /// Returns the lesser of the two given values.
    ///
    /// This method returns the minimum of two values, preserving order and
    /// eliminating NaN when possible. For two values `x` and `y`, the result of
    /// `minimum(x, y)` is `x` if `x <= y`, `y` if `y < x`, or whichever of `x`
    /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
    /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
    ///
    ///     Double.minimum(10.0, -25.0)
    ///     // -25.0
    ///     Double.minimum(10.0, .nan)
    ///     // 10.0
    ///     Double.minimum(.nan, -25.0)
    ///     // -25.0
    ///     Double.minimum(.nan, .nan)
    ///     // nan
    ///
    /// The `minimum` method implements the `minNum` operation defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: The minimum of `x` and `y`, or whichever is a number if the
    ///   other is NaN.
    public static func minimum(_ x: DecimalFP64, _ y: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return x
    }

    /// Returns the greater of the two given values.
    ///
    /// This method returns the maximum of two values, preserving order and
    /// eliminating NaN when possible. For two values `x` and `y`, the result of
    /// `maximum(x, y)` is `x` if `x > y`, `y` if `x <= y`, or whichever of `x`
    /// or `y` is a number if the other is a quiet NaN. If both `x` and `y` are
    /// NaN, or either `x` or `y` is a signaling NaN, the result is NaN.
    ///
    ///     Double.maximum(10.0, -25.0)
    ///     // 10.0
    ///     Double.maximum(10.0, .nan)
    ///     // 10.0
    ///     Double.maximum(.nan, -25.0)
    ///     // -25.0
    ///     Double.maximum(.nan, .nan)
    ///     // nan
    ///
    /// The `maximum` method implements the `maxNum` operation defined by the
    /// [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: The greater of `x` and `y`, or whichever is a number if the
    ///   other is NaN.
    public static func maximum(_ x: DecimalFP64, _ y: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return x
    }

    /// Returns the value with lesser magnitude.
    ///
    /// This method returns the value with lesser magnitude of the two given
    /// values, preserving order and eliminating NaN when possible. For two
    /// values `x` and `y`, the result of `minimumMagnitude(x, y)` is `x` if
    /// `x.magnitude <= y.magnitude`, `y` if `y.magnitude < x.magnitude`, or
    /// whichever of `x` or `y` is a number if the other is a quiet NaN. If both
    /// `x` and `y` are NaN, or either `x` or `y` is a signaling NaN, the result
    /// is NaN.
    ///
    ///     Double.minimumMagnitude(10.0, -25.0)
    ///     // 10.0
    ///     Double.minimumMagnitude(10.0, .nan)
    ///     // 10.0
    ///     Double.minimumMagnitude(.nan, -25.0)
    ///     // -25.0
    ///     Double.minimumMagnitude(.nan, .nan)
    ///     // nan
    ///
    /// The `minimumMagnitude` method implements the `minNumMag` operation
    /// defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: Whichever of `x` or `y` has lesser magnitude, or whichever is
    ///   a number if the other is NaN.
    public static func minimumMagnitude(_ x: DecimalFP64, _ y: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return x
    }

    /// Returns the value with greater magnitude.
    ///
    /// This method returns the value with greater magnitude of the two given
    /// values, preserving order and eliminating NaN when possible. For two
    /// values `x` and `y`, the result of `maximumMagnitude(x, y)` is `x` if
    /// `x.magnitude > y.magnitude`, `y` if `x.magnitude <= y.magnitude`, or
    /// whichever of `x` or `y` is a number if the other is a quiet NaN. If both
    /// `x` and `y` are NaN, or either `x` or `y` is a signaling NaN, the result
    /// is NaN.
    ///
    ///     Double.maximumMagnitude(10.0, -25.0)
    ///     // -25.0
    ///     Double.maximumMagnitude(10.0, .nan)
    ///     // 10.0
    ///     Double.maximumMagnitude(.nan, -25.0)
    ///     // -25.0
    ///     Double.maximumMagnitude(.nan, .nan)
    ///     // nan
    ///
    /// The `maximumMagnitude` method implements the `maxNumMag` operation
    /// defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameters:
    ///   - x: A floating-point value.
    ///   - y: Another floating-point value.
    /// - Returns: Whichever of `x` or `y` has greater magnitude, or whichever is
    ///   a number if the other is NaN.
    public static func maximumMagnitude(_ x: DecimalFP64, _ y: DecimalFP64) -> DecimalFP64 {
        assertionFailure("not implemented yet")
        return x
    }

    /// Nested Class for use in rounding methods
    // left here for comparison of the quite confusing names...
    /*
     enum RoundingMethod {
     case toNearestOrAwayFromZero // RoundHalfUp      ///< normal european style
     case toNearestOrEven         // RoundHalfEven    ///< USA bankers style
     case towardZero              // RoundDown        ///< round towards zero, truncate
     case awayFromZero            // RoundUp          ///< round away from zero, unusual
     case down                    // RoundFloor       ///< round toward -infinity
     case up                      // RoundCelling     ///< round toward +infinity
     }
     */


    ////////////////////////////////////////////////////////////////////////////
    /// Round a DecimalFP64 according to the given digits and rounding method.
    ///
    /// - Parameters:   scale      The number of digits right from the decimal point.
    /// - Parameters:   method     The rounding method. @see DecimalFP64::RoundingMethod
    /// - Returns:  DecimalFP64      The rounded number.
    mutating func round( _ scale: Int, _ method: FloatingPointRoundingRule )
    {
        let expScale = getExponent() + scale

        //TODO: should work with negative scale
        if expScale < 0 {
            var man = getMantissa()
            let sig = Data & DecimalFP64.SIG_MASK

            var remainder: Int64 = 0
            var half: Int64 = 5
            if method != .towardZero {
                if expScale >= -16  {
                    remainder = man % PowerOf10[ -( expScale ) ]
                }
                else if man != 0 {
                    remainder = 1
                }
                if ( method != .awayFromZero ) && ( expScale >= -18 ) {
                    half *= PowerOf10[ -( expScale ) - 1 ]
                }
            }

            // first round down
            shiftDigits( &man, expScale )

            switch method {
            case .toNearestOrAwayFromZero:
                if ( remainder >= half ) {
                    man += 1
                }
            case .toNearestOrEven:
                if ( ( remainder > half ) || ( ( remainder == half ) && (( man & Int64(1)) != 0) ) ) {
                    man += 1
                }
            case .towardZero: break
            case .awayFromZero:
                if remainder != 0 {
                    man += 1
                }
            case .down:
                if sig != 0 && remainder != 0 {
                    man += 1
                }
            case .up:
                if sig == 0 && remainder != 0 {
                    man += 1
                }
            @unknown default:
                fatalError()
            }

            Data = man
            Data |= sig
            Data |= Int64( -scale ) << DecimalFP64.EXP_SHIFT
        }
    }

    // Arithmetical operations (see GDA specification) they all return *this
    static func round( _ op: DecimalFP64, _ exp: Int = 0, _ method: FloatingPointRoundingRule = .toNearestOrAwayFromZero ) -> DecimalFP64
    {
        var ret = op
        ret.round(exp, method)
        return ret
    }

    /// Returns this value rounded to an integral value using the specified
    /// rounding rule.
    ///
    /// The following example rounds a value using four different rounding rules:
    ///
    ///     let x = 6.5
    ///
    ///     // Equivalent to the C 'round' function:
    ///     print(x.rounded(.toNearestOrAwayFromZero))
    ///     // Prints "7.0"
    ///
    ///     // Equivalent to the C 'trunc' function:
    ///     print(x.rounded(.towardZero))
    ///     // Prints "6.0"
    ///
    ///     // Equivalent to the C 'ceil' function:
    ///     print(x.rounded(.up))
    ///     // Prints "7.0"
    ///
    ///     // Equivalent to the C 'floor' function:
    ///     print(x.rounded(.down))
    ///     // Prints "6.0"
    ///
    /// For more information about the available rounding rules, see the
    /// `FloatingPointRoundingRule` enumeration. To round a value using the
    /// default "schoolbook rounding", you can use the shorter `rounded()`
    /// method instead.
    ///
    ///     print(x.rounded())
    ///     // Prints "7.0"
    ///
    /// - Parameter rule: The rounding rule to use.
    /// - Returns: The integral value found by rounding using `rule`.
    ///
    /// - SeeAlso: `rounded()`, `round(_:)`, `FloatingPointRoundingRule`
    public func rounded(_ rule: FloatingPointRoundingRule) -> DecimalFP64
    {
        var this = self
        this.round(rule)
        return this
    }

    /// Rounds the value to an integral value using the specified rounding rule.
    ///
    /// The following example rounds a value using four different rounding rules:
    ///
    ///     // Equivalent to the C 'round' function:
    ///     var w = 6.5
    ///     w.round(.toNearestOrAwayFromZero)
    ///     // w == 7.0
    ///
    ///     // Equivalent to the C 'trunc' function:
    ///     var x = 6.5
    ///     x.round(.towardZero)
    ///     // x == 6.0
    ///
    ///     // Equivalent to the C 'ceil' function:
    ///     var y = 6.5
    ///     y.round(.up)
    ///     // y == 7.0
    ///
    ///     // Equivalent to the C 'floor' function:
    ///     var z = 6.5
    ///     z.round(.down)
    ///     // z == 6.0
    ///
    /// For more information about the available rounding rules, see the
    /// `FloatingPointRoundingRule` enumeration. To round a value using the
    /// default "schoolbook rounding", you can use the shorter `round()` method
    /// instead.
    ///
    ///     var w1 = 6.5
    ///     w1.round()
    ///     // w1 == 7.0
    ///
    /// - Parameter rule: The rounding rule to use.
    ///
    /// - SeeAlso: `round()`, `rounded(_:)`, `FloatingPointRoundingRule`
    public mutating func round(_ rule: FloatingPointRoundingRule) {
        round( 0, rule)
    }

    /// The least representable value that compares greater than this value.
    ///
    /// For any finite value `x`, `x.nextUp` is greater than `x`. For `nan` or
    /// `infinity`, `x.nextUp` is `x` itself. The following special cases also
    /// apply:
    ///
    /// - If `x` is `-infinity`, then `x.nextUp` is `-greatestFiniteMagnitude`.
    /// - If `x` is `-leastNonzeroMagnitude`, then `x.nextUp` is `-0.0`.
    /// - If `x` is zero, then `x.nextUp` is `leastNonzeroMagnitude`.
    /// - If `x` is `greatestFiniteMagnitude`, then `x.nextUp` is `infinity`.
    public var nextUp: DecimalFP64 {
        assertionFailure("not implemented")
        return self
    }

    /// The greatest representable value that compares less than this value.
    ///
    /// For any finite value `x`, `x.nextDown` is greater than `x`. For `nan` or
    /// `-infinity`, `x.nextDown` is `x` itself. The following special cases
    /// also apply:
    ///
    /// - If `x` is `infinity`, then `x.nextDown` is `greatestFiniteMagnitude`.
    /// - If `x` is `leastNonzeroMagnitude`, then `x.nextDown` is `0.0`.
    /// - If `x` is zero, then `x.nextDown` is `-leastNonzeroMagnitude`.
    /// - If `x` is `-greatestFiniteMagnitude`, then `x.nextDown` is `-infinity`.
    public var nextDown: DecimalFP64 {
        assertionFailure("not implemented")
        return self
    }

    /// Returns a Boolean value indicating whether this instance is equal to the
    /// given value.
    ///
    /// This method serves as the basis for the equal-to operator (`==`) for
    /// floating-point values. When comparing two values with this method, `-0`
    /// is equal to `+0`. NaN is not equal to any value, including itself. For
    /// example:
    ///
    ///     let x = 15.0
    ///     x.isEqual(to: 15.0)
    ///     // true
    ///     x.isEqual(to: .nan)
    ///     // false
    ///     Double.nan.isEqual(to: .nan)
    ///     // false
    ///
    /// The `isEqual(to:)` method implements the equality predicate defined by
    /// the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to compare with this value.
    /// - Returns: `true` if `other` has the same value as this instance;
    ///   otherwise, `false`.
    public func isEqual(to other: DecimalFP64) -> Bool {
        return self == other
    }

    /// Returns a Boolean value indicating whether this instance is less than the
    /// given value.
    ///
    /// This method serves as the basis for the less-than operator (`<`) for
    /// floating-point values. Some special cases apply:
    ///
    /// - Because NaN compares not less than nor greater than any value, this
    ///   method returns `false` when called on NaN or when NaN is passed as
    ///   `other`.
    /// - `-infinity` compares less than all values except for itself and NaN.
    /// - Every value except for NaN and `+infinity` compares less than
    ///   `+infinity`.
    ///
    ///     let x = 15.0
    ///     x.isLess(than: 20.0)
    ///     // true
    ///     x.isLess(than: .nan)
    ///     // false
    ///     Double.nan.isLess(than: x)
    ///     // false
    ///
    /// The `isLess(than:)` method implements the less-than predicate defined by
    /// the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to compare with this value.
    /// - Returns: `true` if `other` is less than this value; otherwise, `false`.
    public func isLess(than other: DecimalFP64) -> Bool {
        return self < other
    }

    /// Returns a Boolean value indicating whether this instance is less than or
    /// equal to the given value.
    ///
    /// This method serves as the basis for the less-than-or-equal-to operator
    /// (`<=`) for floating-point values. Some special cases apply:
    ///
    /// - Because NaN is incomparable with any value, this method returns `false`
    ///   when called on NaN or when NaN is passed as `other`.
    /// - `-infinity` compares less than or equal to all values except NaN.
    /// - Every value except NaN compares less than or equal to `+infinity`.
    ///
    ///     let x = 15.0
    ///     x.isLessThanOrEqualTo(20.0)
    ///     // true
    ///     x.isLessThanOrEqualTo(.nan)
    ///     // false
    ///     Double.nan.isLessThanOrEqualTo(x)
    ///     // false
    ///
    /// The `isLessThanOrEqualTo(_:)` method implements the less-than-or-equal
    /// predicate defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: The value to compare with this value.
    /// - Returns: `true` if `other` is less than this value; otherwise, `false`.
    public func isLessThanOrEqualTo(_ other: DecimalFP64) -> Bool {
        return self < other || self == other
    }

    /// Returns a Boolean value indicating whether this instance should precede the
    /// given value in an ascending sort.
    ///
    /// This relation is a refinement of the less-than-or-equal-to operator
    /// (`<=`) that provides a total order on all values of the type, including
    /// noncanonical encodings, signed zeros, and NaNs. Because it is used much
    /// less frequently than the usual comparisons, there is no operator form of
    /// this relation.
    ///
    /// The following example uses `isTotallyOrdered(below:)` to sort an array of
    /// floating-point values, including some that are NaN:
    ///
    ///     var numbers = [2.5, 21.25, 3.0, .nan, -9.5]
    ///     numbers.sort { $0.isTotallyOrdered(below: $1) }
    ///     // numbers == [-9.5, 2.5, 3.0, 21.25, nan]
    ///
    /// The `isTotallyOrdered(belowOrEqualTo:)` method implements the total order
    /// relation as defined by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    ///
    /// - Parameter other: A floating-point value to compare to this value.
    /// - Returns: `true` if this value is ordered below `other` in a total
    ///   ordering of the floating-point type; otherwise, `false`.
    public func isTotallyOrdered(belowOrEqualTo other: DecimalFP64) -> Bool {
        return isLessThanOrEqualTo(other) //TODO: ???
    }

    /// A Boolean value indicating whether this instance is normal.
    ///
    /// A *normal* value is a finite number that uses the full precision
    /// available to values of a type. Zero is neither a normal nor a subnormal
    /// number.
    public var isNormal: Bool {
        assertionFailure("not yet implemented")
        return true
    }

    /// A Boolean value indicating whether this instance is finite.
    ///
    /// All values other than NaN and infinity are considered finite, whether
    /// normal or subnormal.
    public var isFinite: Bool {
        assertionFailure("not yet implemented")
        return true
    }

    /// A Boolean value indicating whether the instance is equal to zero.
    ///
    /// The `isZero` property of a value `x` is `true` when `x` represents either
    /// `-0.0` or `+0.0`. `x.isZero` is equivalent to the following comparison:
    /// `x == 0.0`.
    ///
    ///     let x = -0.0
    ///     x.isZero        // true
    ///     x == 0.0        // true
    public var isZero: Bool {
        return self == 0.0
    }

    /// A Boolean value indicating whether the instance is subnormal.
    ///
    /// A *subnormal* value is a nonzero number that has a lesser magnitude than
    /// the smallest normal number. Subnormal values do not use the full
    /// precision available to values of a type.
    ///
    /// Zero is neither a normal nor a subnormal number. Subnormal numbers are
    /// often called *denormal* or *denormalized*---these are different names
    /// for the same concept.
    public var isSubnormal: Bool {
        assertionFailure("not yet implemented")
        return false
    }

    /// A Boolean value indicating whether the instance is infinite.
    ///
    /// Note that `isFinite` and `isInfinite` do not form a dichotomy, because
    /// they are not total: If `x` is `NaN`, then both properties are `false`.
    public var isInfinite: Bool {
        assertionFailure("not yet implemented")
        return false
    }

    func isQuiteNaN() -> Bool {
        return Data == 0x7F80000000000000
    }

    /// A Boolean value indicating whether the instance is NaN ("not a number").
    ///
    /// Because NaN is not equal to any value, including NaN, use this property
    /// instead of the equal-to operator (`==`) or not-equal-to operator (`!=`)
    /// to test whether a value is or is not NaN. For example:
    ///
    ///     let x = 0.0
    ///     let y = x * .infinity
    ///     // y is a NaN
    ///
    ///     // Comparing with the equal-to operator never returns 'true'
    ///     print(x == Double.nan)
    ///     // Prints "false"
    ///     print(y == Double.nan)
    ///     // Prints "false"
    ///
    ///     // Test with the 'isNaN' property instead
    ///     print(x.isNaN)
    ///     // Prints "false"
    ///     print(y.isNaN)
    ///     // Prints "true"
    ///
    /// This property is `true` for both quiet and signaling NaNs.
    public var isNaN: Bool {
        return isQuiteNaN() || isSignalingNaN
    }

    /// A Boolean value indicating whether the instance is a signaling NaN.
    ///
    /// Signaling NaNs typically raise the Invalid flag when used in general
    /// computing operations.
    public var isSignalingNaN: Bool {
        return false
    }

    /// The classification of this value.
    ///
    /// A value's `floatingPointClass` property describes its "class" as
    /// described by the [IEEE 754 specification][spec].
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    public var floatingPointClass: FloatingPointClassification {
        if isNaN {
            // we don't have .signalingNaN
            return .quietNaN
        }

        if getSign() {
            if isInfinity() {
                return .negativeInfinity
            }
            if isZero {
                return .negativeZero
            }
            if isNormal {
                return .negativeNormal
            }
            return .negativeSubnormal
        }

        if isInfinity() {
            return .positiveInfinity
        }
        if isZero {
            return .positiveZero
        }
        if isNormal {
            return .positiveNormal
        }
        return .positiveSubnormal
    }

    /// A Boolean value indicating whether the instance's representation is in
    /// the canonical form.
    ///
    /// The [IEEE 754 specification][spec] defines a *canonical*, or preferred,
    /// encoding of a floating-point value's representation. Every `Float` or
    /// `Double` value is canonical, but noncanonical values of the `Float80`
    /// type exist, and noncanonical values may exist for other types that
    /// conform to the `FloatingPoint` protocol.
    ///
    /// [spec]: http://ieeexplore.ieee.org/servlet/opac?punumber=4610933
    public var isCanonical: Bool {
        return true //FIXME: for now I just don't care
    }

    func getSign() -> Bool {
        return (Data & DecimalFP64.SIG_MASK) != 0
    }

    /// Return the exponent (incl. NaN, Inf)
    func getExponent() -> Int {
        return Int(Data >> DecimalFP64.EXP_SHIFT)
    }

    // Return the positive mantissa
    func getMantissa() -> Int64 {
        return Data & DecimalFP64.MAN_MASK
    }

    /// This methods sets the internal represantation according to the
    /// parameters coefficient, exponent and sign.
    /// The result is never Not-a-Number(NaN) but can be
    /// +/- infinity if the exponent is to large or zero if the exponent is
    /// to small
    ///
    /// - Parameters:
    ///   - mantissa: coefficient of result
    ///   - exponent: exponent of result valid range is -256 to +253
    ///   - negative: Sign of the result (-0 is valid and distinct from +0 (but compares equal))
    mutating func setComponents( _ mantissa: Int64, _ exponent: Int = 0, _ negative: Bool = false) {
        var mantissa = mantissa
        var exponent = exponent
        var negative = negative
        // exponent  255 is NaN (we don't care about sign from NaN)
        // exponent  254 is +/- infinity

        if  mantissa < 0 {
            mantissa = -mantissa
            negative = !negative
        }

        if  mantissa == 0 {
            Data = 0
        }
        else
        {
            // Round the internal coefficient to a maximum of 16 digits.
            if mantissa >= TenPow16  {
                if mantissa < TenPow17  {
                    mantissa += 5
                    mantissa /= 10
                    exponent += 1
                }
                else if mantissa < TenPow18 {
                    mantissa += 50
                    mantissa /= 100
                    exponent += 2
                }
                else {
                    // Adding 500 may cause an overflow in signed Int64.
                    mantissa += 500
                    mantissa /= 1000
                    exponent += 3
                }
            }

            Data = mantissa

            // try denormalization if possible
            if exponent > 253 {
                exponent -= int64_shiftLeftTo16( &Data ) //TODO: numbers with exponent > 253 may be denormalized to much

                if exponent > 253 {
                    setInfinity()
                }
                else {
                    Data |= Int64( exponent ) << DecimalFP64.EXP_SHIFT
                }
            }
            else if  exponent < -256 {
                shiftDigits( &Data, exponent + 256 )

                if Data != 0 {
                    Data |= -256 << DecimalFP64.EXP_SHIFT
                }
            }
            else if exponent != 0 {
                Data |= Int64(exponent) << DecimalFP64.EXP_SHIFT
            }
        }

        // change sign
        if negative {
            Data |= DecimalFP64.SIG_MASK
        }
    }

    // Arithmetical operations (see GDA specification) they all return *this
    /// The result is non-negative
    mutating func abs() {
        Data &= ~DecimalFP64.SIG_MASK
    }
    static func abs( _ op: DecimalFP64 ) -> DecimalFP64 { var ret = op; ret.abs(); return ret }

    /// The functions break the number into integral and fractional parts.
    /// After completion, this contains the signed integral part.
    ///
    /// - Returns:  DecimalFP64      The unsigned fractional part of this.
    mutating func decompose() -> DecimalFP64 {
        var fracPart: DecimalFP64 = self

        round( 0, .towardZero )
        fracPart -= self
        fracPart.abs()
        return fracPart
    }

    mutating func minus() {
        Data ^= DecimalFP64.SIG_MASK
    }

    mutating func setSign( _ negative: Bool )
    {
        if negative {
            Data |= DecimalFP64.SIG_MASK
        }
        else {
            Data &= ~DecimalFP64.SIG_MASK
        }
    }

    ///  Compare two DecimalFP64.
    ///
    /// - Parameters:   left  Number to compare.
    /// - Parameters:   right  Number to compare.
    ///
    /// - Returns:  true   Both are equal ( A == B ).
    /// - Returns:  false  Both differ ( A != B ).
    static func ==( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    {
        var ret = false

        var leftMan = left.getMantissa()
        var rightMan = right.getMantissa()

        if ( (left.Data & SIG_MASK) == (right.Data & SIG_MASK) ) // Same as left.getSign() == right.getSign() but faster.
        {
            var leftExp = left.getExponent()
            var rightExp = right.getExponent()

            if ( ( leftExp == rightExp ) || ( leftMan == 0 ) || ( rightMan == 0 ) )
            {
                ret = ( leftMan == rightMan )
            }
            else if ( ( leftExp > rightExp - 18 ) && ( leftExp < rightExp ) )
            {
                // Try to make rightExp smaller to make it equal to leftExp.
                rightExp -= int64_shiftLeftTo17orLim( &rightMan, rightExp - leftExp )

                if ( leftExp == rightExp )
                {
                    ret = ( leftMan == rightMan )
                }
            }
            else if ( ( leftExp < rightExp + 18 ) && ( leftExp > rightExp ) )
            {
                // Try to make leftExp smaller to make it equal to rightExp.
                leftExp -= int64_shiftLeftTo17orLim( &leftMan, leftExp - rightExp )

                if ( leftExp == rightExp )
                {
                    ret = ( leftMan == rightMan )
                }
            }
            else
            {
                // The exponents differ more than +-17,
                // therefore the numbers can never be equal.
            }
        }
        else
        {
            // A >= 0 and B <= 0 or A <= 0 and B >= 0.
            ret = ( leftMan == 0 ) && ( rightMan == 0 )
        }

        return ret
    }

    ///  Compare two DecimalFP64.
    ///
    /// - Parameters:   left  Number to compare.
    /// - Parameters:   right  Number to compare.
    ///
    /// - Returns:  true   A is smaller than B ( A < B ).
    /// - Returns:  false  A is bigger or equal to B ( A >= B ).
    static func <( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    {
        var ret = false
        let leftSign = left.getSign()
        let rightSign = right.getSign()

        if leftSign && !rightSign {
            // A <= 0 and B >= 0.
            ret = ( left.getMantissa() != 0 ) || ( right.getMantissa() != 0 )
        }
        else if !leftSign && rightSign {
            // A >= 0 and B <= 0.
            ret = false
        }
        else
        {
            // Both are either positive or negative or 0.
            var leftMan = left.getMantissa()
            var rightMan = right.getMantissa()

            var leftExp = left.getExponent()
            var rightExp = right.getExponent()

            // Lets assume both are positive.
            if ( ( leftExp == rightExp ) || ( leftMan == 0 ) || ( rightMan == 0 ) )
            {
                ret = ( leftMan < rightMan )
            }
            else if ( rightExp >= leftExp + 18 )
            {
                // A > B > 0.
                ret = true
            }
            else if ( rightExp > leftExp - 18 )
            {
                // -18 < rightExp - leftExp < 18 and A,B > 0.
                if ( leftExp < rightExp )
                {
                    // Try to make rightExp smaller to make it equal to leftExp.
                    rightExp -= int64_shiftLeftTo17orLim( &rightMan, rightExp - leftExp )

                    // If rightExp is greater than leftExp then rightMan > TenPow16 > leftMan.
                    ret = true
                }
                else
                {
                    // Try to make leftExp smaller to make it equal to rightExp.
                    leftExp -= int64_shiftLeftTo17orLim( &leftMan, leftExp - rightExp )

                    // If leftExp is greater than rightExp then leftMan > TenPow16 > rightMan.
                }

                if ( leftExp == rightExp )
                {
                    ret = ( leftMan < rightMan )
                }
            }
            else
            {
                // rightExp <= leftExp - 18 and A,B > 0. => A > B, therefore false.
            }

            // If both are negative and not equal then ret = ! ret.
            if leftSign {
                if ret {
                    ret = false
                }
                else
                {
                    ret = ( leftExp != rightExp ) || ( leftMan != rightMan )
                }
            }
        }

        return ret
    }

    ///  Compute the sum of the absolute values of this and a second DecimalFP64.
    ///  All signs are ignored !
    ///
    /// - Parameters:   right    Summand.
    mutating func addToThis( _ right: DecimalFP64, _ negative: Bool )
    {
        var myExp = getExponent()
        var otherExp = right.getExponent()

        if ( myExp > 253 ) || ( otherExp > 253 ) { // equivalent to ( !isNumber() || !right.isNumber() ) but faster
            if ( ( myExp <= 254 ) && ( otherExp <= 254 ) ) {
                setInfinity()

                if negative {
                    minus()
                }
            }
            else {
                setNaN()
            }
        }
        else {
            // Calculate new coefficient
            var myMan = getMantissa()
            var otherMan = right.getMantissa()

            if otherMan == 0 {
                // Nothing to do because NumB is 0.
            }
            else if myExp == otherExp {
                setComponents( myMan + otherMan, myExp, negative )
            }
            else if ( myExp < otherExp - 32 ) || ( myMan == 0 ) {
                // This is too small, therefore sum is completely sign * |NumB|.
                Data = right.Data
                setSign( negative )
            }
            else if ( myExp <= otherExp + 32 ) {
                // -32 <= myExp - otherExp <= 32
                if ( myExp < otherExp ) {
                    // Make otherExp smaller.
                    otherExp -= int64_shiftLeftTo17orLim( &otherMan, min( 17, otherExp - myExp ) )
                    if ( myExp != otherExp ) {
                        if ( otherExp > myExp + 16 ) {
                            // This is too small, therefore sum is completely sign * |NumB|.
                            Data = right.Data
                            setSign( negative )
                            return
                        }

                        // myExp is still smaller than otherExp, make it bigger.
                        myMan /= PowerOf10[ otherExp - myExp ]
                        myExp = otherExp
                    }
                }
                else {
                    // Make myExp smaller.
                    myExp -= int64_shiftLeftTo17orLim( &myMan, min( 17, myExp - otherExp ) )
                    if ( myExp != otherExp ) {
                        if ( myExp > otherExp + 16 ) {
                            // Nothing to do because NumB is too small
                            return
                        }

                        // otherExp is still smaller than myExp, make it bigger.
                        otherMan /= PowerOf10[ myExp - otherExp ]
                    }
                }

                // Now both exponents are equal.
                setComponents( myMan + otherMan, myExp, negative )
            }
            else {
                // Nothing to do because NumB is too small
                // otherExp < myExp - 32.
            }
        }
    }

    /// Subtract the absolute value of a DecimalFP64 from the absolute value of this.
    /// The sign is flipped if the result is negative.
    ///
    /// - Parameters:
    ///   - right: Subtrahend
    ///   - negative: flag if ... is negative
    mutating func subtractFromThis( _ right: DecimalFP64, _ negative: Bool )
    {
        var myExp = getExponent()
        var otherExp = right.getExponent()

        if ( myExp > 253 || otherExp > 253 ) // equivalent to ( !isNumber() || !right.isNumber() ) but faster
        {
            if ( ( myExp == 254 ) && ( otherExp <= 254 ) )
            {
                // Nothing to do
            }
            else if ( ( myExp <= 253 ) && ( otherExp == 254 ) )
            {
                setInfinity()

                if negative {
                    minus()
                }
            }
            else
            {
                setNaN()
            }
        }
        else
        {
            // Calculate new coefficient
            var myMan = getMantissa()
            var otherMan = right.getMantissa()

            if ( otherMan == 0 )
            {
                // Nothing to do because NumB is 0.
            }
            else if ( myExp == otherExp )
            {
                setComponents( myMan - otherMan, myExp, negative )
            }
            else if ( ( myExp < otherExp - 32 ) || ( myMan == 0 ) )
            {
                // This is too small, therefore difference is completely -sign * |NumB|.
                Data = right.Data
                setSign( !negative )
            }
            else if ( myExp <= otherExp + 32 )
            {
                // -32 <= myExp - otherExp <= 32
                if ( myExp < otherExp )
                {
                    // Make otherExp smaller.
                    otherExp -= int64_shiftLeftTo17orLim( &otherMan, min( 17, otherExp - myExp ) )
                    if ( myExp != otherExp )
                    {
                        if ( otherExp > myExp + 16 )
                        {
                            // This is too small, therefore difference is completely -sign * |NumB|.
                            Data = right.Data
                            setSign( !negative )
                            return
                        }

                        // myExp is still smaller than otherExp, make it bigger.
                        myMan /= PowerOf10[ otherExp - myExp ]
                        myExp = otherExp
                    }
                }
                else
                {
                    // Make myExp smaller.
                    myExp -= int64_shiftLeftTo17orLim( &myMan, min( 17, myExp - otherExp ) )
                    if ( myExp != otherExp )
                    {
                        if ( myExp > otherExp + 16 )
                        {
                            // Nothing to do because NumB is too small
                            return
                        }

                        // otherExp is still smaller than myExp, make it bigger.
                        otherMan /= PowerOf10[ myExp - otherExp ]
                    }
                }

                // Now both exponents are equal.
                setComponents( myMan - otherMan, myExp, negative )
            }
            else
            {
                // Nothing to do because NumB is too small (myExp > otherExp + 32).
            }
        }
    }

    static func +(_ left: DecimalFP64, _ right: DecimalFP64) -> DecimalFP64 {
        var ret = left
        ret += right
        return ret
    }

    static func -(_ left: DecimalFP64, _ right: DecimalFP64) -> DecimalFP64 {
        var ret = left
        ret -= right
        return ret
    }

    static func *(_ left: DecimalFP64, _ right: DecimalFP64) -> DecimalFP64 {
        var ret = left
        ret *= right
        return ret
    }

    static func /(_ left: DecimalFP64, _ right: DecimalFP64) -> DecimalFP64 {
        var ret = left
        ret /= right
        return ret
    }

    ///  assignment decimal shift left
    ///
    /// - Parameters:   shift     Number of decimal digits to shift to the left.
    ///
    /// - Returns:  DecimalFP64 ( this * 10^shift )
    static func <<=( _ left: inout DecimalFP64, _ shift: Int )
    {
        left.setComponents( left.getMantissa(), left.getExponent() + shift, left.getSign() )
    }

    ///  assignment decimal shift right
    ///
    /// - Parameters:   shift     Number of decimal digits to shift to the right.
    ///
    /// - Returns:  DecimalFP64 ( this / 10^shift )
    static func >>=( _ left: inout DecimalFP64, _ shift: Int )
    {
        left.setComponents( left.getMantissa(), left.getExponent() - shift, left.getSign() )
    }

    ///  Add a number to this.
    ///
    ///    |a| < |b|          |a| > |b|
    ///  a+b | + | -        a+b | + | -
    ///  ----+---+---       ----+---+---
    ///   +  |+a+|+s-        +  |+a+|+s+
    ///  ----+---+---       ----+---+---
    ///   -  |-s+|-a-        -  |-s-|-a-
    ///
    /// - Parameters:    right  Summand.
    ///
    /// - Returns:  ( this + A )
    static func += (_ left: inout DecimalFP64, _ right: DecimalFP64 )
    {
        let sign = left.getSign()

        if sign == right.getSign() {
            left.addToThis( right, sign )
        }
        else {
            left.subtractFromThis( right, sign )
        }
    }

    ///  Subtract a number from this.
    ///
    ///    |a| < |b|          |a| > |b|
    ///  a-b | + | -        a-b | + | -
    ///  ----+---+---       ----+---+---
    ///   +  |+s-|+a+        +  |+s+|+a+
    ///  ----+---+---       ----+---+---
    ///   -  |-a-|-s+        -  |-a-|-s-
    ///
    /// - Parameters:    right  Subtrahend
    ///
    /// - Returns:  DecimalFP64 ( this - A )
    static func -=(_ left: inout DecimalFP64, _ right: DecimalFP64 )
    {
        let sign = left.getSign()

        if  sign == right.getSign() {
            left.subtractFromThis( right, sign )
        }
        else {
            left.addToThis( right, sign )
        }
    }

    /// Multiply this by a number.
    ///     newExp = aExp + bExp + shift
    ///     newMan = ah*bh * 10^(16-shift) + (ah*bl + al*bh) * 10^(8-shift) +
    ///              al*bl * 10^-shift
    /// shift is a unique integer so that newMan fits into 54 bits with the
    /// highest accuracy.
    ///
    /// - Parameters:   right   Factor.
    ///
    /// - Returns:  DecimalFP64 ( this * B )
    static func *=( _ left: inout DecimalFP64, _ right: DecimalFP64 )
    {
        var myExp = left.getExponent()
        let rightExp = right.getExponent()

        if ( myExp > 253 || rightExp > 253 ) // equivalent to ( !isNumber() || !right.isNumber() ) but faster
        {
            // Infinity is reached if one or both of the exp are 254
            if ( ( myExp <= 254 ) && ( rightExp <= 254 ) )
            {
                let flipSign = left.getSign() != right.getSign()
                left.setInfinity()

                if ( flipSign ) {
                    left.minus()
                }
            }
                // NaN is set if both exp are greater than 254
            else
            {
                left.setNaN()
            }
        }
        else if ( right.Data == 0 || left.Data == 0 ) {
            left.Data = 0
        }
        else
        {
            // Calculate new coefficient
            var myHigh = left.getMantissa()
            let myLow  = myHigh % TenPow8
            myHigh /= TenPow8

            var otherHigh = right.getMantissa()
            let otherLow  = otherHigh % TenPow8
            otherHigh /= TenPow8

            var newHigh = myHigh * otherHigh
            var newMid  = myHigh * otherLow + myLow * otherHigh
            var myMan = myLow * otherLow

            var shift = 0

            if ( newHigh > 0 )
            {
                // Make high as big as possible.
                shift = 16 - int64_shiftLeftTo17_16( &newHigh )

                if ( shift > 8 )
                {
                    newMid /= PowerOf10[ shift - 8 ]
                    myMan /= PowerOf10[ shift ]
                }
                else
                {
                    newMid *= PowerOf10[ 8 - shift ]
                    myMan /= PowerOf10[ shift ]
                }

                myMan += newHigh + newMid
            }
            else if ( newMid > 0 )
            {
                // Make mid as big as possible.
                shift = 8 - int64_shiftLeftTo17_8( &newMid )
                myMan /= PowerOf10[ shift ]
                myMan += newMid
            }

            // Calculate new exponent.
            myExp += rightExp + shift

            left.setComponents( myMan, myExp, left.getSign() != right.getSign() )
        }
    }

    ///  Divide this by a number.
    ///  Using the following algorithm:
    ///  a = r0, f0*r0 = n0*b + r1, f1*r1 = n1*b + r2, ...
    ///  where fi are factors (power of 10) to make remainders ri as big as
    ///  possible and ni are integers. Then with g a power of 10 to make n0
    ///  as big as possible:
    ///     a     1              g          g
    ///     - = ---- * ( g*n0 + -- * n1 + ----- * n2 + ... )
    ///     b   f0*g            f1        f1*f2
    ///
    /// - Parameters:
    ///   - left: number to be divided
    ///   - right: Divisor
    static func /=( _ left: inout DecimalFP64, _ right: DecimalFP64 )
    {
        var myExp = left.getExponent()
        let rightExp = right.getExponent()

        var myMan = left.getMantissa()
        let otherMan = right.getMantissa()

        if ( ( myExp > 253 ) || ( rightExp > 253 ) ) // equivalent to ( !isNumber() || !right.isNumber() ) but faster
        {
            if ( ( myExp == 254 ) && ( rightExp <= 254 ) )
            {
                let flipSign = (left.getSign() != right.getSign())
                left.setInfinity()

                if ( flipSign ){
                    left.minus()
                }
            }
            else if ( ( myExp <= 253 ) && ( rightExp == 254 ) )
            {
                left.Data = 0
            }
            else
            {
                left.setNaN()
            }
        }
        else if ( otherMan == 0 )
        {
            let sign = left.getSign()
            left.setInfinity()

            if sign {
                left.minus()
            }
        }
        else if ( myMan != 0 ) && ( right.Data != 1 )
        {
            // Calculate new coefficient

            // First approach of result.
            // Make numerator as big as possible.
            var mainShift = int64_shiftLeftTo18( &myMan )

            // Do division.
            var remainderA = myMan % otherMan
            myMan /= otherMan

            // Make result as big as possible.
            var shift = int64_shiftLeftTo18( &myMan )
            mainShift += shift

            while ( remainderA > 0 )
            {
                shift -= int64_shiftLeftTo18( &remainderA )
                if ( shift < -17 )
                {
                    break
                }

                // Do division.
                let remainderB = remainderA % otherMan
                remainderA /= otherMan

                shiftDigits( &remainderA, shift )

                if ( remainderA == 0 )
                {
                    break
                }

                myMan += remainderA

                remainderA = remainderB
            }

            // Calculate new exponent.
            myExp -= rightExp + mainShift

            left.setComponents( myMan, myExp, left.getSign() != right.getSign() )
        }
    }

    static prefix func -( _ op: DecimalFP64 ) -> DecimalFP64 { var ret = op; ret.minus(); return ret }

    mutating func square_root()                        ///< square root
    {
        //TODO: Implement square_root
        fatalError()
    }
    mutating func div( _ right: DecimalFP64 )              ///< Integer divide
    {
        //TODO: Implement integer divide
        fatalError()
    }
    mutating func power( _ right: DecimalFP64 )            ///< self^right
    {
        //TODO: Implement power
        fatalError()
    }
    mutating func remainder( _ right: DecimalFP64 )        ///< remainder from integer divide
    {
        //TODO: Implement remainder
        fatalError()
    }
    mutating func remainder_near( _ right: DecimalFP64 )   ///< nearest remainder
    {
        //TODO: Implement remainder_near
        fatalError()
    }

    static func square_root( _ op: DecimalFP64 ) -> DecimalFP64
    { var ret = op; ret.square_root(); return ret }
    static func div( _ left: DecimalFP64, _ right: DecimalFP64 ) -> DecimalFP64
    { var ret = left; ret.div( right ); return ret }
    static func power( _ left: DecimalFP64, _ right: DecimalFP64 ) -> DecimalFP64
    { var ret = left; ret.power( right ); return ret }
    static func remainder( _ left: DecimalFP64, _ right: DecimalFP64 ) -> DecimalFP64
    { var ret = left; ret.remainder( right ); return ret }
    static func remainder_near( _ left: DecimalFP64, _ right: DecimalFP64 ) -> DecimalFP64
    { var ret = left; ret.remainder_near( right ); return ret }

    /// if sometime a high-performance swift is available...
    /// maybe a non-throwing swap is necessary
    ///
    /// - Parameter other: the other value that will be exchanged with self
    mutating func swap(other: inout DecimalFP64) {
        let temp = other
        other = self
        self = temp
    }

    // TBD which is... methods are necessary
    func isNegative() -> Bool {
        return (Data & DecimalFP64.SIG_MASK) == DecimalFP64.SIG_MASK
    }

    func isInfinity() -> Bool {
        return Data & DecimalFP64.EXP_MASK == 0x7F00000000000000
    }

    mutating func setNaN() { Data = 0x7F80000000000000 } //TODO: keep sign and coefficient
    mutating func setInfinity() { Data = 0x7F3FFFFFFFFFFFFF } // Infinity is greater than any valid number.

    /// Convert type to an signed integer (64bit)
    ///
    /// - Parameter limit: The maximum value to be returned, otherwise an exception is thrown
    /// - Returns: Self as signed integer
    func toInt( _ limit: Int64 ) -> Int64
    {
        var exp = getExponent()

        if ( exp >= -16 )
        {
            var man = getMantissa()
            var shift = 0

            if exp < 0 {
                man /= PowerOf10[ -exp ]
                exp = 0
            }
            else  if ( ( exp > 0 ) && ( exp <= 17 ) ) {
                shift = int64_shiftLeftTo17orLim( &man, exp )
            }

            if ( ( man > limit ) || ( shift != exp ) ) {
                //FIXME: learn exception handling in swift...
                // throw DecimalFP64::OverflowExceptionParam( 1, *this, ( exp - shift ) )
                fatalError()
            }

            if getSign() {
                return -man
            }
            else {
                return man
            }
        }

        return 0
    }

    static func !=( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    { return !( left  == right ) }
    static func >=( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    { return !( left  <  right ) }
    static func <=( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    { return !( right < left )  }
    static func >( _ left: DecimalFP64, _ right: DecimalFP64 ) -> Bool
    { return    right < left     }

    static func<<( _ left: DecimalFP64, _ right: Int ) -> DecimalFP64
    { var ret = left; ret <<= right; return ret }
    static func >>( _ left: DecimalFP64, _ right: Int ) -> DecimalFP64
    { var ret = left; ret >>= right; return ret }

    static let EXP_MASK = Int64(bitPattern: 0xFF80000000000000)  ///< bitmask for exponent
    static let MAN_MASK = Int64(bitPattern: 0x003FFFFFFFFFFFFF)  ///< bitmask for coefficient
    static let SIG_MASK = Int64(bitPattern: 0x0040000000000000)  ///< bitmask for sign-bit
    static let EXP_SHIFT: Int64 = 55                             ///< number of coefficient + sign bits

    var Data: Int64 = 0

    init(_ value: Double) {
        var isNegative = false
        var value = value

        if ( value < 0 )
        {
            isNegative = true
            value = -value
        }

        let exp = Int( log10( value ) - 15 )
        let man = Int64( value / pow( 10.0, DecimalFP64.FloatLiteralType( exp ) ) + 0.5 )

        setComponents( man, exp, isNegative )
    }

    func getString() -> String {
        // optimized after Instruments showed that this function used 1/4 of all the time...
        //      var ca: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        //      return String(cString: toChar(&ca[0]))
        var ca: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            ) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        return String(cString: toChar(&ca.0))
    }
}

extension DecimalFP64: CustomStringConvertible {
    var description: String {
        return getString()
    }
}

extension DecimalFP64: ExpressibleByFloatLiteral
{
    typealias FloatLiteralType = Double

    init(floatLiteral value: DecimalFP64.FloatLiteralType) {
        self.init( value )
    }
}

extension DecimalFP64: ExpressibleByIntegerLiteral
{
    typealias IntegerLiteralType = Int64

    init(integerLiteral value: DecimalFP64.IntegerLiteralType) {
        self.init( value )
    }
}

extension DecimalFP64: Strideable
{
    typealias Stride = DecimalFP64
    /// Returns a stride `x` such that `self.advanced(by: x)` approximates
    /// `other`.
    ///
    /// If `Stride` conforms to `Integer`, then `self.advanced(by: x) == other`.
    ///
    /// - Complexity: O(1).
    func distance(to other: DecimalFP64) -> DecimalFP64 {
        return other - self
    }

    /// Returns a `Self` `x` such that `self.distance(to: x)` approximates `n`.
    ///
    /// If `Stride` conforms to `Integer`, then `self.distance(to: x) == n`.
    ///
    /// - Complexity: O(1).
    func advanced(by n: DecimalFP64) -> DecimalFP64 {
        return self + n
    }
}

extension DecimalFP64: TextOutputStreamable
{
    func write<Target>(to target: inout Target) where Target : TextOutputStream {
        var data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                   UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        ) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

        guard !isNaN else {
            target.write("NaN")
            return
        }

        guard !isInfinity() else {
            if getSign() {
                target.write("-Inf")
            }
            else {
                target.write("Inf")
            }
            return
        }

        let man = getMantissa()
        guard man != 0 else {
            target.write("0")
            return
        }

        var exp = getExponent()
        withUnsafeMutablePointer(to: &data.30) { end in
            var end = end
            var start = ll2str( man, end )

            if ( exp < 0 ) {
                end -= 1

                // Try to set a decimal point to make exp equal to zero.
                // Strip off trailing zeroes.
                while ( end.pointee == 0x30 ) && ( exp < 0 ) {
                    end -= 1
                    exp += 1
                }

                if exp < 0 {
                    if exp > start - end - 6 {
                        // Add maximal 6 additional chars left from digits to get
                        // 0.nnn, 0.0nnn, 0.00nnn, 0.000nnn, 0.0000nnn or 0.00000nnn.
                        // The result may have more than 16 digits.
                        while start - end > exp {
                            start -= 1
                            start.pointee = 0x30 // 0
                        }
                    }

                    let dotPos = ( end - start ) + exp + 1
                    // exp < 0 therefore start + dotPos <= end.
                    if dotPos > 0 {
                        memmove( start + dotPos + 1, start + dotPos, 1 - exp )
                        start[ dotPos ] = 0x2E // .
                        exp = 0
                        end += 2
                    }
                    else {
                        if end != start {
                            let fb = start.pointee
                            start.pointee = 0x2E // .
                            start -= 1
                            start.pointee = fb
                        }

                        exp = 1 - dotPos

                        end += 1
                        end.pointee = 0x45 // E
                        end += 1
                        end.pointee = 0x2D // -

                        end += 2
                        if exp >= 10 {
                            end += 1
                        }
                        if exp >= 100 {
                            end += 1
                        }
                        _ = ll2str( Int64(exp), end )
                    }
                }
                else {
                    end += 1
                }
            }
            else if exp + end - start > 16 {
                end -= 1

                exp += end - start //TODO: will it work on 64bit?

                while  end.pointee == 0x30 { // 0
                    end -= 1
                }

                if end != start {
                    let fb = start.pointee
                    start.pointee = 0x2E // .
                    start -= 1
                    start.pointee = fb
                }
                end += 1
                end.pointee = 0x45 // E
                end += 1
                end.pointee = 0x2B // +

                end += 2
                if exp >= 10 {
                    end += 1
                }
                if exp >= 100 {
                    end += 1
                }
                _ = ll2str( Int64(exp), end )
            }
            else {
                while exp > 0 {
                    end.pointee = 0x30 // 0
                    end += 1
                    exp -= 1
                }
            }

            if getSign() {
                start -= 1
                start.pointee = 0x2D // -
            }

            end.pointee = 0
            target._writeASCII(UnsafeBufferPointer<UInt8>(start: start, count: end - start))
        }
    }
}

// converting to String
extension DecimalFP64
{
    /// This function converts number to decimal and produces the string.
    /// It returns  a pointer to the beginning of the string. No leading
    /// zeros are produced, and no terminating null is produced.
    /// The low-order digit of the result always occupies memory position end-1.
    /// The behavior is undefined if number is negative. A single zero digit is
    /// produced if number is 0.
    ///
    /// - Parameters:
    ///   - x: The number.
    ///   - end: Pointer to the end of the buffer.
    /// - Returns: Pointer to beginning of the string.
    private func ll2str(_ x: Int64, _ end: UnsafeMutablePointer<UInt8> ) -> UnsafeMutablePointer<UInt8>
    {
        var x = x
        var end = end

        while x >= 10000 {
            let y = Int(x % 10000)
            x /= 10000
            end -= 4
            memcpy(end, DecimalFP64.int64LookUp.Pointer + y * 4, 4)
        }

        var dig = 1
        if x >= 100 {
            if x >= 1000 {
                dig = 4
            } else {
                dig = 3
            }
        } else if x >= 10 {
            dig = 2
        }
        end -= dig

        memcpy(end, DecimalFP64.int64LookUp.Pointer + Int(x) * 4 + 4 - dig, dig)

        return end
    }

    // possibly not the fastest swift way. but for now the easiest way to port some c++ code
    private func strcpy( _ buffer: UnsafeMutablePointer<UInt8>, _ content: String ) -> UnsafeMutablePointer<UInt8> {
        var pos = buffer

        for c in content.utf8 {
            pos.pointee = c
            pos += 1
        }
        return buffer
    }

    func toChar( _ buffer: UnsafeMutablePointer<UInt8> ) -> UnsafeMutablePointer<UInt8>
    {

        if isNaN {
            return strcpy( buffer, "NaN" )
        }

        if isInfinity() {
            if getSign() {
                return strcpy( buffer, "-Inf" )
            }
            else {
                return strcpy( buffer, "Inf" )
            }
        }

        let man = getMantissa()

        if man == 0 {
            return strcpy( buffer, "0" )
        }

        var exp = getExponent()
        var end = buffer.advanced(by: 30)
        var start = ll2str( man, end )

        if ( exp < 0 ) {
            end -= 1

            // Try to set a decimal point to make exp equal to zero.
            // Strip off trailing zeroes.
            while ( end.pointee == 0x30 ) && ( exp < 0 ) {
                end -= 1
                exp += 1
            }

            if exp < 0 {
                if exp > start - end - 6 {
                    // Add maximal 6 additional chars left from digits to get
                    // 0.nnn, 0.0nnn, 0.00nnn, 0.000nnn, 0.0000nnn or 0.00000nnn.
                    // The result may have more than 16 digits.
                    while start - end > exp {
                        start -= 1
                        start.pointee = 0x30 // 0
                    }
                }

                let dotPos = ( end - start ) + exp + 1
                // exp < 0 therefore start + dotPos <= end.
                if dotPos > 0 {
                    memmove( start + dotPos + 1, start + dotPos, 1 - exp )
                    start[ dotPos ] = 0x2E // .
                    exp = 0
                    end += 2
                }
                else {
                    if end != start {
                        let fb = start.pointee
                        start.pointee = 0x2E // .
                        start -= 1
                        start.pointee = fb
                    }

                    exp = 1 - dotPos

                    end += 1
                    end.pointee = 0x45 // E
                    end += 1
                    end.pointee = 0x2D // -

                    end += 2
                    if exp >= 10 {
                        end += 1
                    }
                    if exp >= 100 {
                        end += 1
                    }
                    _ = ll2str( Int64(exp), end )
                }
            }
            else {
                end += 1
            }
        }
        else if exp + end - start > 16 {
            end -= 1

            exp += end - start //TODO: will it work on 64bit?

            while  end.pointee == 0x30 { // 0
                end -= 1
            }

            if end != start {
                let fb = start.pointee
                start.pointee = 0x2E // .
                start -= 1
                start.pointee = fb
            }
            end += 1
            end.pointee = 0x45 // E
            end += 1
            end.pointee = 0x2B // +

            end += 2
            if exp >= 10 {
                end += 1
            }
            if exp >= 100 {
                end += 1
            }
            _ = ll2str( Int64(exp), end )
        }
        else {
            while exp > 0 {
                end.pointee = 0x30 // 0
                end += 1
                exp -= 1
            }
        }

        if getSign() {
            start -= 1
            start.pointee = 0x2D // -
        }

        end.pointee = 0

        return start
    }


    class LookUpTable {
        var Pointer: UnsafeMutablePointer<UInt8>

        init() {
            Pointer = UnsafeMutablePointer<UInt8>.allocate(capacity: 40000)
            var fill = Pointer
            for i in 0...9999 {
                var val = i
                fill.pointee = UInt8(val / 1000) + 48
                val %= 1000
                fill += 1
                fill.pointee = UInt8(val / 100) + 48
                val %= 100
                fill += 1
                fill.pointee = UInt8(val / 10) + 48
                val %= 10
                fill += 1
                fill.pointee = UInt8(val) + 48
                fill += 1
            }
        }

        deinit {
            Pointer.deallocate()
        }

        subscript(index: Int) -> UInt8 {
            return (Pointer + index).pointee
        }
    }

    static let int64LookUp = LookUpTable()
}
