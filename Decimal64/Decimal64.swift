//
//  Decimal64.swift
//  Decimal64
//
//  Created by Dirk on 18.07.19.
//  Copyright © 2019 Dirk Schreib. All rights reserved.
//

import Foundation

/// start again from scratch
/// this is a new implementation of Decimal (final name is tbd)
/// It will use
/// - 55 bit for mantissa
/// -  9 bit for exponent
/// both will be stored as a twos complement in case of negative numbers.
///  63                                          9 8            0
///  +--------------------------------------------+--------------+
///  |           mantissa                         |   exponent   |
///  +--------------------------------------------+--------------+
public struct Decimal64
{
    public typealias Exponent = Int
    public typealias Significand = Int64
    public typealias InternalType = Int64

    // not sure if this is ever needed (was included in FloatingPoint)
    public static let radix = 10

    static let exponentBitCount = 9
    static let significandBitCount = 55
    static let exponentBitMask = Int64(bitPattern: 0x1FF)
    static let significandBitMask = Int64(bitPattern: 0xFFFFFFFFFFFFFE00)
    static let EXP_MIN = -256
    static let EXP_MAX = 255

    private var _data: InternalType = 0

    // we will not silently convert numbers with more than 16 digits to Decimal
    public init?(_ man: Significand) {
        guard Swift.abs(man) < 10_000_000_000_000_000 else { return nil }
        _data = man << Decimal64.exponentBitCount
    }

    public init?(_ man: Significand, withExponent exp: Exponent) {
        guard Swift.abs(man) < 10_000_000_000_000_000 else { return nil }
        guard ( exp >= -256 ) && (exp <= 255 ) else { return nil }
        
        _data = ( man << Decimal64.exponentBitCount ) | (InternalType(exp) & Decimal64.exponentBitMask )
    }

    public init?(_ value: Double, _ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) {
        guard value.isFinite else { return nil }
        guard !value.isZero else { self.init(0, withExponent: 0); return }

        /// always use all 16 available decimal digits and round the result using .toNearestOrAwayFromZero or given rule
        let sign  = value < 0
        let value = Swift.abs(value)
        let exp   = Int( log10(value).rounded(.down) ) - 15
        let man   = Int64( (value * pow( 10.0, Double(-exp) )).rounded(rule) )

        self.init( sign ? -man: man, withExponent: exp )
    }

    /// returns the mantissa with a simple bit shift. This will remove the exponent automatically
    var significand: Significand {
        return (_data & Decimal64.significandBitMask) >> Decimal64.exponentBitCount
    }

    /// the exponent is in 2's complement. To restore the sign all mantissa bits have to be set to the high bit of the exponent (sign extension)
    var exponent: Exponent {
        // the left-shift right-shift sequence restores the sign of the exponent
         return Exponent((( _data & Decimal64.exponentBitMask ) << Decimal64.significandBitCount ) >> Decimal64.significandBitCount)
        //Exponent( sign ? _data | Decimal64.MAN_MASK : _data & Decimal64.EXP_MASK )
    }

    public var sign: Bool {
        return _data < 0
    }

    public var floatingPointSign: FloatingPointSign {
        if sign {
            return .minus
        } else {
            return .plus
        }
    }
    /// Mutating operations on the sign
    mutating func abs() {
        if _data < 0 {
            self.minus()
        }
    }

    mutating func minus() {
         _data = ( -significand << Decimal64.exponentBitCount ) | (InternalType(exponent) & Decimal64.exponentBitMask )
     }

    public static var greatestFiniteMagnitude: Decimal64 {
        return Decimal64(9_999_999_999_999_999, withExponent: EXP_MAX )!
    }

    public static var leastNonzeroMagnitude: Decimal64 {
        return Decimal64(1, withExponent: EXP_MIN )!
    }

    public func adding(_ other: Decimal64) -> Decimal64 {
        var left = self
        left += other
        return left
    }

    public mutating func add(_ other: Decimal64) {
        self += other
    }

    public func negated() -> Decimal64 {
        var left = self
        left.minus()
        return left
    }

    public func subtracting(_ other: Decimal64) -> Decimal64 {
        var left = self
        left -= other
        return left
    }

    public mutating func subtract(_ other: Decimal64) {
        self -= other
    }

    public func multiplied(by other: Decimal64) -> Decimal64 {
        var left = self
        left *= other
        return left
    }

    public mutating func multiply (by other: Decimal64) {
        self *= other
    }

    public func divided(by other: Decimal64) -> Decimal64 {
        var left = self
        left /= other
        return left
    }

    public mutating func divide(by other: Decimal64) {
        self /= other
    }

    ////////////////////////////////////////////////////////////////////////////
    /// Round a Decimal64 according to the given digits and rounding method.
    ///
    /// @param   scale      The number of digits right from the decimal point.
    /// @param   method     The rounding method. @see FloatingPointRoiundingRule
    /// @retval  Decimal64      The rounded number.
    mutating func round( _ scale: Int, _ method: FloatingPointRoundingRule )
    {
        let expScale = exponent + scale

        //TODO: should work with negative scale
        if expScale < 0 {
            var man = sign ? -significand: significand

            var remainder: Int64 = 0
            var half: Int64 = 5
            if method != .towardZero {
                if expScale >= -16  {
                    remainder = man % PowerOf10[ -( expScale ) ];
                }
                else if man != 0 {
                    remainder = 1
                }
                if ( method != .awayFromZero ) && ( expScale >= -18 ) {
                    half *= PowerOf10[ -( expScale ) - 1 ]
                }
            }

            // first round down
            shiftDigits( &man, expScale );

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
                if sign && ( remainder != 0 ) {
                    man += 1
                }
            case .up:
                if !sign && (remainder != 0 ) {
                    man += 1
                }
            @unknown default:
                fatalError()
            }

            if sign {
                man = -man
            }
            _data = man << Decimal64.exponentBitCount
            _data |= Int64( -scale )
        }
    }

    // Arithmetical operations (see GDA specification) they all return *this
    static func round( _ op: Decimal64, _ exp: Int = 0, _ method: FloatingPointRoundingRule = .toNearestOrAwayFromZero ) -> Decimal64
    {
        var ret = op
        ret.round(exp, method)
        return ret
    }

    public func rounded(_ rule: FloatingPointRoundingRule) -> Decimal64
    {
        var this = self
        this.round(rule)
        return this
    }

    public mutating func round(_ rule: FloatingPointRoundingRule) {
        round( 0, rule)
    }

    public func isEqual(to other: Decimal64) -> Bool {
        return self == other
    }

    public func isLess(than other: Decimal64) -> Bool {
        return self < other
    }

    public func isLessThanOrEqualTo(_ other: Decimal64) -> Bool {
        return self < other || self == other
    }

    public func isTotallyOrdered(belowOrEqualTo other: Decimal64) -> Bool {
        return isLessThanOrEqualTo(other) //TODO: ???
    }

    // keep for rounding functions which may be needed in init
    //TODO: refactor with better handling of negative values
    mutating func setComponents( _ man: Int64, _ exp: Int = 0, _ negative: Bool = false) {
        var man = man
        var exp = exp
        var negative = negative

        if  man < 0 {
            man = -man
            negative = !negative
        }

        if  man == 0 {
            _data = 0
        }
        else
        {
            // Round the internal coefficient to a maximum of 16 digits.
            if man >= TenPow16  {
                if man < TenPow17  {
                    man += 5
                    man /= 10
                    exp += 1
                }
                else if man < TenPow18 {
                    man += 50
                    man /= 100
                    exp += 2
                }
                else {
                    // Adding 500 may cause an overflow in signed Int64.
                    man += 500
                    man /= 1000
                    exp += 3
                }
            }
            // change sign
            if negative {
                man = -man
            }

            _data = man << Decimal64.exponentBitCount

            // try denormalization if possible
            if exp > 253 {
                exp -= int64_shiftLeftTo16( &_data ) //TODO: numbers with exponent > 253 may be denormalized to much
                _data |= Int64( exp )
            }
            else if  exp < -256 {
                shiftDigits( &_data, exp + 256 )

                if _data != 0 {
                    _data |= -256
                }
            }
            else if exp != 0 {
                _data |=  (InternalType(exp) & Decimal64.exponentBitMask )
            }
        }

    }

    /// The functions break the number into integral and fractional parts.
    /// After completion, this contains the signed integral part.
    ///
    /// @retval  Decimal64      The unsigned fractional part of this.
    mutating func decompose() -> Decimal64 {
        var fracPart: Decimal64 = self

        round( 0, .towardZero )
        fracPart -= self
        fracPart.abs()
        return fracPart
    }

    public func normalized() -> Decimal64 {
        /// make exp as small as possible (min is -256)
        if significand == 0 {
            return Decimal64(0)
        } else {
            var man = significand
            var exp = exponent
            exp -= toMaximumDigits( &man )
            return Decimal64( man, withExponent: exp)!
        }
    }

    ///  Compare two Decimal64.
    ///
    /// @param   left  Number to compare.
    /// @param   right  Number to compare.
    ///
    /// @retval  true   A is smaller than B ( A < B ).
    /// @retval  false  A is bigger or equal to B ( A >= B ).
    public static func <( _ left: Decimal64, _ right: Decimal64 ) -> Bool
    {
        // special cases 1: internal representation is identical
        if  left._data == right._data {
            return false
        }

        // special cases 2/3: one mantissa is zero
        // (special case 4: both mantissa are zero with different exponents is handled automatically by the ordering of the following ifs)
        if right.significand == 0 {
            return left.sign
        }
        if left.significand == 0 {
            return !right.sign
        }

        // normal case 1: different signs
        if left.sign != right.sign {
            return left.sign
        }

        // normal case 2: same sign. Here we have to normalize and check the exponent
        let l = left.normalized()
        let r = right.normalized()

        if l.exponent == r.exponent {
            return l.significand < r.significand
        }

        return (l.exponent < r.exponent) != l.sign
    }

    ///  Compute the sum of the absolute values of this and a second Decimal64.
    ///  All signs are ignored !
    ///
    /// @param   right    Summand.
    mutating func addToThis( _ right: Decimal64, _ negative: Bool )
    {
        var myExp = exponent
        var otherExp = right.exponent

        // Calculate new coefficient
        var myMan = significand
        var otherMan = right.significand

        if otherMan == 0 {
            // Nothing to do because NumB is 0.
        }
        else if myExp == otherExp {
            setComponents( myMan + otherMan, myExp, negative )
        }
        else if ( myExp < otherExp - 32 ) || ( myMan == 0 ) {
            // This is too small, therefore sum is completely sign * |NumB|.
            _data = right._data
            if negative {
                _data = -_data
            }
        }
        else if ( myExp <= otherExp + 32 ) {
            // -32 <= myExp - otherExp <= 32
            if ( myExp < otherExp ) {
                // Make otherExp smaller.
                otherExp -= int64_shiftLeftTo17orLim( &otherMan, min( 17, otherExp - myExp ) )
                if ( myExp != otherExp ) {
                    if ( otherExp > myExp + 16 ) {
                        // This is too small, therefore sum is completely sign * |NumB|.
                        _data = right._data
                        if negative {
                            _data = -_data
                        }
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

    /// Subtract the absolute value of a Decimal64 from the absolute value of this.
    /// The sign is flipped if the result is negative.
    ///
    /// - Parameters:
    ///   - right: Subtrahend
    ///   - negative: flag if ... is negative
    mutating func subtractFromThis( _ right: Decimal64, _ negative: Bool )
    {
        var myExp = exponent
        var otherExp = right.exponent

        // Calculate new coefficient
        var myMan = significand
        var otherMan = right.significand

        if ( otherMan == 0 )
        {
            // Nothing to do because NumB is 0.
        }
        else if ( myExp == otherExp )
        {
            setComponents( myMan - otherMan, myExp, negative );
        }
        else if ( ( myExp < otherExp - 32 ) || ( myMan == 0 ) )
        {
            // This is too small, therefore difference is completely -sign * |NumB|.
            _data = right._data
            if !negative {
                _data = -_data
            }
        }
        else if ( myExp <= otherExp + 32 )
        {
            // -32 <= myExp - otherExp <= 32
            if ( myExp < otherExp )
            {
                // Make otherExp smaller.
                otherExp -= int64_shiftLeftTo17orLim( &otherMan, min( 17, otherExp - myExp ) );
                if ( myExp != otherExp )
                {
                    if ( otherExp > myExp + 16 )
                    {
                        // This is too small, therefore difference is completely -sign * |NumB|.
                        _data = right._data
                        if !negative {
                            _data = -_data
                        }
                        return
                    }

                    // myExp is still smaller than otherExp, make it bigger.
                    myMan /= PowerOf10[ otherExp - myExp ];
                    myExp = otherExp;
                }
            }
            else
            {
                // Make myExp smaller.
                myExp -= int64_shiftLeftTo17orLim( &myMan, min( 17, myExp - otherExp ) );
                if ( myExp != otherExp )
                {
                    if ( myExp > otherExp + 16 )
                    {
                        // Nothing to do because NumB is too small
                        return;
                    }

                    // otherExp is still smaller than myExp, make it bigger.
                    otherMan /= PowerOf10[ myExp - otherExp ];
                }
            }

            // Now both exponents are equal.
            setComponents( myMan - otherMan, myExp, negative );
        }
        else
        {
            // Nothing to do because NumB is too small (myExp > otherExp + 32).
        }

    }

    static func +(_ left: Decimal64, _ right: Decimal64) -> Decimal64 {
        var ret = left
        ret += right
        return ret
    }

    static func -(_ left: Decimal64, _ right: Decimal64) -> Decimal64 {
        var ret = left
        ret -= right
        return ret
    }

    static func *(_ left: Decimal64, _ right: Decimal64) -> Decimal64 {
        var ret = left
        ret *= right
        return ret
    }

    static func /(_ left: Decimal64, _ right: Decimal64) -> Decimal64 {
        var ret = left
        ret /= right
        return ret
    }

    ///  assignment decimal shift left
    ///
    /// @param   shift     Number of decimal digits to shift to the left.
    ///
    /// @retval  Decimal64 ( this * 10^shift )
    static func <<=( _ left: inout Decimal64, _ shift: Int )
    {
        left.setComponents( left.significand, left.exponent + shift, left.sign )
    }

    ///  assignment decimal shift right
    ///
    /// @param   shift     Number of decimal digits to shift to the right.
    ///
    /// @retval  Decimal64 ( this / 10^shift )
    static func >>=( _ left: inout Decimal64, _ shift: Int )
    {
        left.setComponents( left.significand, left.exponent - shift, left.sign )
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
    /// @param    right  Summand.
    ///
    /// @retval  ( this + A )
    static func += (_ left: inout Decimal64, _ right: Decimal64 )
    {
        let sign = left.sign

        if sign == right.sign {
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
    /// @param    right  Subtrahend
    ///
    /// @retval  Decimal64 ( this - A )
    static func -=(_ left: inout Decimal64, _ right: Decimal64 )
    {
        let sign = left.sign

        if  sign == right.sign {
            left.subtractFromThis( right, sign )
        }
        else {
            left.addToThis( right, sign );
        }
    }

    /// Multiply this by a number.
    ///     newExp = aExp + bExp + shift
    ///     newMan = ah*bh * 10^(16-shift) + (ah*bl + al*bh) * 10^(8-shift) +
    ///              al*bl * 10^-shift
    /// shift is a unique integer so that newMan fits into 54 bits with the
    /// highest accuracy.
    ///
    /// @param   right   Factor.
    ///
    /// @retval  Decimal64 ( this * B )
    static func *=( _ left: inout Decimal64, _ right: Decimal64 )
    {
        var myExp = left.exponent
        let rightExp = right.exponent

        if ( right._data == 0 || left._data == 0 ) {
            left._data = 0
        }
        else
        {
            // Calculate new coefficient
            var myHigh = left.sign ? -left.significand : left.significand
            let myLow  = myHigh % TenPow8
            myHigh /= TenPow8

            var otherHigh = right.sign ? -right.significand : right.significand
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
            myExp += rightExp + shift;

            left.setComponents( myMan, myExp, left.sign != right.sign )
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
    static func /=( _ left: inout Decimal64, _ right: Decimal64 )
    {
        var myExp = left.exponent
        let rightExp = right.exponent

        var myMan = left.sign ? -left.significand : left.significand
        let otherMan = right.sign ? -right.significand : right.significand

        if ( otherMan == 0 ) {
            fatalError()
        }
        else if ( myMan != 0 ) && ( right._data != 1 )
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

            while ( remainderA > 0 ) {
                shift -= int64_shiftLeftTo18( &remainderA )
                if ( shift < -17 ) {
                    break
                }

                // Do division.
                let remainderB = remainderA % otherMan
                remainderA /= otherMan

                shiftDigits( &remainderA, shift )

                if ( remainderA == 0 ) {
                    break
                }

                myMan += remainderA
                remainderA = remainderB
            }

            // Calculate new exponent.
            myExp -= rightExp + mainShift

            left.setComponents( myMan, myExp, left.sign != right.sign )
        }
    }

    static prefix func -( _ op: Decimal64 ) -> Decimal64 { var ret = op; ret.minus(); return ret }

    /// If eventually a high-performance swift is available...
    /// a non-throwing swap may be necessary
    ///
    /// - Parameter other: swaps value with the other Decimal
    mutating func swap(other: inout Decimal64) {
        let temp = other
        other = self
        self = temp
    }

    /// Convert type to an signed integer (64bit)
    ///
    /// - Parameter limit: The maximum value to be returned, otherwise an exception is thrown
    /// - Returns: Self as signed integer
    func toInt( _ limit: Int64 ) -> Int64
    {
        var exp = exponent

        if ( exp >= -16 ) {
            var man = significand
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
                // throw Decimal64::OverflowExceptionParam( 1, *this, ( exp - shift ) )
                fatalError()
            }

            if sign {
                return -man
            }
            else {
                return man
            }
        }

        return 0
    }

    static func !=( _ left: Decimal64, _ right: Decimal64 ) -> Bool {
        return !( left  == right )
    }

    public static func >=( _ left: Decimal64, _ right: Decimal64 ) -> Bool{
        return !( left  <  right )
    }

    public static func <=( _ left: Decimal64, _ right: Decimal64 ) -> Bool {
        return !( right < left )
    }

    public static func >( _ left: Decimal64, _ right: Decimal64 ) -> Bool {
        return    right < left
    }

    static func<<( _ left: Decimal64, _ right: Int ) -> Decimal64 {
        var ret = left
        ret <<= right
        return ret
    }

    static func >>( _ left: Decimal64, _ right: Int ) -> Decimal64 {
        var ret = left
        ret >>= right
        return ret
    }
}

extension Decimal64: Equatable {
    /// Compare two Decimals
    ///
    /// - Parameters:
    ///   - left: one value
    ///   - right: the other value
    /// - Returns: returns true if both values are the same if normalized
    public static func ==( _ left: Decimal64, _ right: Decimal64 ) -> Bool
    {
        if left._data == right._data {
            return true
        }

        if (left.significand == 0 ) && (right.significand == 0 ) {
            return true
        }

        let expDiff = left.exponent - right.exponent

        if  expDiff < 0 {
            // right has bigger exponent, i.e. smaller mantissa if it is equal
            var rightMantissa = right.significand
            let shift = int64_shiftLeftTo17orLim(&rightMantissa, -expDiff)
            if (shift == -expDiff) && (rightMantissa == left.significand) {
                return true
            }
        }
        else if expDiff > 0 {
            // right has bigger exponent, i.e. smaller mantissa if it is equal
            var leftMantissa = left.significand
            let shift = int64_shiftLeftTo17orLim(&leftMantissa, expDiff)
            if (shift == expDiff) && (leftMantissa == right.significand) {
                return true
            }
        }
        return false
    }
}

extension Decimal64: CustomStringConvertible {
    public var description: String {
        // optimized after Instruments showed that this function used 1/4 of all the time...
        //      var ca: [UInt8] = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
        //      return String(cString: toChar(&ca[0]))
        var data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            ) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
        return String(cString: toChar(&data.0))
    }
}

extension Decimal64: TextOutputStreamable
{
    public func write<Target>(to target: inout Target) where Target : TextOutputStream {
        var data: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            ) = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)

        var man = significand

        if man == 0 {
            target.write("0")
            return
        } else if man < 0 {
            man = -man
        }

        var exp = exponent
        withUnsafeMutableBytes(of: &data) { bytes in
            var end = bytes.count - 10
            var start = ll2str( man, bytes, end )

            if ( exp < 0 ) {
                end -= 1

                // Try to set a decimal point to make exp equal to zero.
                // Strip off trailing zeroes.
                while ( bytes[end] == 0x30 ) && ( exp < 0 ) {
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
                            bytes[start] = 0x30 // 0
                        }
                    }

                    let dotPos = ( end - start ) + exp + 1;
                    // exp < 0 therefore start + dotPos <= end.
                    if dotPos > 0 {
                        memmove( bytes.baseAddress! + start + dotPos + 1, bytes.baseAddress! + start + dotPos, 1 - exp )
                        bytes[ start + dotPos ] = 0x2E // .
                        exp = 0
                        end += 2
                    }
                    else {
                        if end != start {
                            let startMinusOne = start - 1
                            bytes[startMinusOne] = bytes[start]
                            bytes[start] = 0x2E // .
                            start -= 1
                        }

                        exp = 1 - dotPos

                        end += 1
                        bytes[end] = 0x45 // E
                        end += 1
                        bytes[end] = 0x2D // -

                        end += 2
                        if exp >= 10 {
                            end += 1
                        }
                        if exp >= 100 {
                            end += 1
                        }
                        _ = ll2str( Int64(exp), bytes, end )
                    }
                }
                else {
                    end += 1
                }
            }
            else if exp + end - start > 16 {
                end -= 1

                exp += end - start //TODO: will it work on 64bit?

                while bytes[end] == 0x30 { // 0
                    end -= 1
                }

                if end != start {
                    let oldstart = start
                    start -= 1
                    bytes[start] = bytes[oldstart]
                    // print(oldstart) // code will work with this print statement and in debug mode but unfortunately not in release mode
                    bytes[oldstart] = 0x2E // .
                }
                end += 1
                bytes[end] = 0x45 // E
                end += 1
                bytes[end] = 0x2B // +

                end += 2
                if exp >= 10 {
                    end += 1
                }
                if exp >= 100 {
                    end += 1
                }
                _ = ll2str( Int64(exp), bytes, end )
            }
            else {
                while exp > 0 {
                    bytes[end] = 0x30 // 0
                    end += 1
                    exp -= 1
                }
            }

            if sign {
                start -= 1
                bytes[start] = 0x2D // -
            }

            bytes[end] = 0 // may be out of bounds
            let out = UnsafeBufferPointer<UInt8>(start: (bytes.baseAddress! + start).assumingMemoryBound(to: UInt8.self), count: end - start)
            target._writeASCII(out)
        }
    }
}

extension Decimal64: ExpressibleByFloatLiteral
{
    public typealias FloatLiteralType = Double

    // If used as an literal, we assume we can force unwrap it
    public init(floatLiteral value: Decimal64.FloatLiteralType) {
        self.init( value )!
    }
}

extension Decimal64: ExpressibleByIntegerLiteral
{
    public typealias IntegerLiteralType = Int64

    // If used as an literal, we assume we can force unwrap it
    public init(integerLiteral value: Decimal64.IntegerLiteralType) {
        self.init( value )!
    }
}

extension Decimal64: ExpressibleByStringLiteral
{
    public typealias StringLiteralType = String

    /// Reads an Decimal from a string input in the format
    /// ["+"|"-"]? Optional sign
    /// "0".."9"*  any number of digits as integer part
    /// ["." "0".."9"*]? optional a dot with any number of digits as fraction
    /// [("E"|"e") "0".."9"*]? optional an e with any number of digits as exponent
    ///
    /// - Parameter value: the input string
    public init(stringLiteral value: String) {
        self.init(value)!
    }

    public init?(_ value: String) {
        func isDigit( _ c: Character? ) -> Bool {
            return c != nil && c! >= "0" && c! <= "9"
        }

        var iter = value.makeIterator()
        var c = iter.next()

        while c == " " {
            c = iter.next()
        }

        //print(c ?? "END")

        // Check sign
        let sig = ( c == "-" )
        if c == "-"  || c == "+" {
            c = iter.next()
        }

        while c != nil && c! == "0" {
            c = iter.next()
        }

        var man: Int64 = 0
        var exp: Int = 0
        var dig: Int = 0

        // check integer part
        while isDigit(c) && (dig < 18) {
            dig += 1
            man *= 10
            man += Int64(c!.asciiValue! - 48)
            c = iter.next()
        }

        // maybe we have more digits for our precision
        while isDigit(c) {
            exp += 1
            c = iter.next()
        }

        // check fraction part
        if c != nil && c! == "." {
            c = iter.next()

            if man == 0 {
                while c != nil && c! == "0" {
                    exp -= 1
                    c = iter.next()
                }
            }

            while isDigit(c) && (dig < 18) {
                dig += 1
                exp -= 1
                man *= 10
                man += Int64(c!.asciiValue! - 48)
                c = iter.next()
            }

            // maybe we have more digits -> just ignore
            while isDigit(c) {
                c = iter.next()
            }
        }

        if sig {
            man = -man
        }

        if (c != nil) && ((c! == "e") || (c! == "E")) {
            c = iter.next()
            dig = 0
            var e = 0
            var expSign = 1

            if (c != nil) && ((c! == "-") || (c! == "+")) {
                expSign = (c! == "-") ? -1 : 1
                c = iter.next()
            }

            while c != nil && c! == "0" {
                c = iter.next()
            }

            while isDigit(c) && (dig < 3) {
                dig += 1
                e *= 10
                e += Int(c!.asciiValue!) - 48
                c = iter.next()
            }

            exp += e * expSign

            if isDigit(c) {
                while isDigit(c) {
                    c = iter.next()
                }
                return nil
            }
        }
       // print (c ?? "END")
        self.init(man, withExponent: exp)
    }
}



// MARK: helper functions on Int64

/// Internal helper function to shift a number to the left until
/// it fills 16 digits.
///
/// - Parameters:
///   - num: The number to process, must not have more than 18 digits
/// - Returns: count of shifted digits
func toMaximumDigits( _ num: inout Int64 ) -> Int
{
    if num == 0 {
        return 0
    }
    var n = abs(num)
    var ret = 0
    // num will overflow if pushed left, just shift to 16 digits

    if n < TenPow8 {
        if n < TenPow4 {
            ret = 12
            n &*= TenPow12
        }
        else {
            ret = 8
            n &*= TenPow8
        }
    }
    else {
        if n < TenPow12 {
            ret = 4
            n &*= TenPow4
        }
    }

    if n < TenPow14 {
        if n < TenPow13 {
            ret &+= 3
            n &*= 1000
        } else {
            ret &+= 2
            n &*= 100
        }
    } else if n < TenPow15 {
        ret &+= 1
        n &*= 10
    }

    num = (num < 0) ? -n: n
    return ret
}

//converting to String
extension Decimal64
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
    private func ll2str(_ x: Int64, _ end: UnsafeMutableRawPointer ) -> UnsafeMutablePointer<UInt8>
    {
        var x = x
        var end = end

        while x >= 10000 {
            let y = Int(x % 10000)
            x /= 10000
            end -= 4
            memcpy(end, Decimal64.int64LookUp.Pointer + y * 4, 4)
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

        memcpy(end, Decimal64.int64LookUp.Pointer + Int(x) * 4 + 4 - dig, dig)

        return UnsafeMutablePointer<UInt8>.init(OpaquePointer( end))
    }

    private func ll2str(_ x: Int64, _ bytes: UnsafeMutableRawBufferPointer, _ end: Int ) -> Int
    {
        var x = x
        var end = end

        while x >= 10000 {
            let y = Int(x % 10000)
            x /= 10000
            end -= 4
            memcpy(bytes.baseAddress! + end, Decimal64.int64LookUp.Pointer + y * 4, 4)
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

        memcpy(bytes.baseAddress! + end, Decimal64.int64LookUp.Pointer + Int(x) * 4 + 4 - dig, dig)

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
        let man = sign ? -significand: significand

        if man == 0 {
            return strcpy( buffer, "0" )
        }

        var exp = exponent
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

                let dotPos = ( end - start ) + exp + 1;
                // exp < 0 therefore start + dotPos <= end.
                if dotPos > 0 {
                    memmove( start + dotPos + 1, start + dotPos, 1 - exp )
                    start[ dotPos ] = 0x2E // .
                    exp = 0
                    end += 2
                }
                else {
                    if end != start {
                        let startMinusOne = start.advanced(by: -1)
                        startMinusOne.pointee = start.pointee
                        start.pointee = 0x2E // .
                        start -= 1
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
                let startMinusOne = start.advanced(by: -1)
                startMinusOne.pointee = start.pointee
                start.pointee = 0x2E // .
                start -= 1
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

        if sign {
            start -= 1
            start.pointee = 0x2D // -
        }

        end.pointee = 0

        return start
    }


    struct LookUpTable {
        var Pointer: UnsafeMutableRawPointer

        init() {
            Pointer = UnsafeMutableRawPointer.allocate( byteCount: 40000, alignment: 8 )
            var fill = Pointer
            for i in 0...9999 {
                var val = i
                fill.storeBytes(of: UInt8(val / 1000) + 48, as: UInt8.self)
                val %= 1000
                fill += 1
                fill.storeBytes(of: UInt8(val / 100) + 48, as: UInt8.self)
                val %= 100
                fill += 1
                fill.storeBytes(of: UInt8(val / 10) + 48, as: UInt8.self)
                val %= 10
                fill += 1
                fill.storeBytes(of: UInt8(val) + 48, as: UInt8.self)
                fill += 1
            }
        }
    }

    static let int64LookUp = LookUpTable()

}
