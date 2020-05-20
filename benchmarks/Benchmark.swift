import Decimals
import Foundation

internal enum Benchmark {
    /// This is a small benchmark for +,*,/ and conversion to string
    /// Version for builtin Double (64bit)
    ///
    /// - Parameter start: the starting value for the calculations in the
    /// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
    static func double(start: Double) -> String  {
        var s = start
        s /= Double(10) // my value in sec
        s /= Double(60) // my value in min
        var ret: String = ""
        for _ in 0...9999 {
            
            let ppm: Double = 9.9
            
            let net = s * ppm
            let taxrate = Double(19) / Double(100)
            let tax = net * taxrate
            let gross = net + tax
            
            ret = "\(s), net: \(net), tax: \(tax), gross: \(gross)"
            //        ret = s.description + ", net: " + net.description + ", tax: " + tax.description + ", gross: " + gross.description
            s += 1.1
        }
        return ret
    }
}

extension Benchmark {
    /// This is a small benchmark for +,*,/ and conversion to string
    /// Version for builtin Decimal (160bit)
    ///
    /// - Parameter start: the starting value for the calculations in the
    /// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
    static func decimal(start: Decimal) -> String  {
        var s = start
        s /= Decimal(10) // my value in sec
        s /= Decimal(60) // my value in min
        var ret: String = ""
        for _ in 0...9999 {
            
            let ppm: Decimal = 9.9
            
            let net = s * ppm
            let taxrate = Decimal(19) / Decimal(100)
            let tax = net * taxrate
            let gross = net + tax
            
            ret = "\(s), net: \(net), tax: \(tax), gross: \(gross)"
            s += 1.1
        }
        return ret
    }
}

extension Benchmark {
    /// This is a small benchmark for +,*,/ and conversion to string
    /// Version for DecimalFP64 (64bit) which conforms to the FloatingPoint protocol
    ///
    /// - Parameter start: the starting value for the calculations in the
    /// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
    static func decimalFP64(start: DecimalFP64) -> String  {
        var s = start
        s /= DecimalFP64(10) // my value in sec
        s /= DecimalFP64(60) // my value in min
        var ret: String = ""
        for _ in 0...9999 {
            
            let ppm: DecimalFP64 = 9.9
            
            let net = s * ppm
            let taxrate = DecimalFP64(19) / DecimalFP64(100)
            let tax = net * taxrate
            let gross = net + tax
            
            ret = "\(s), net: \(net), tax: \(tax), gross: \(gross)"
            s += 1.1
        }
        return ret
    }
}

extension Benchmark {
    /// This is a small benchmark for +,*,/ and conversion to string
    /// Version for Decimal64 (64bit) which does NOT conforms to the FloatingPoint protocol
    ///
    /// - Parameter start: the starting value for the calculations in the
    /// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
    static func decimal64(start: Decimal64) -> String  {
        var s = start
        s /= Decimal64(10) // my value in sec
        s /= Decimal64(60) // my value in min
        var ret: String = ""
        for _ in 0...9999 {
            
            let ppm: Decimal64 = 9.9
            
            let net = s * ppm
            let taxrate = Decimal64(19) / Decimal64(100)
            let tax = net * taxrate
            let gross = net + tax
            
            ret = "\(s), net: \(net), tax: \(tax), gross: \(gross)"
            s += 1.1
        }
        return ret
    }
}

extension Benchmark {
    /// This is a small benchmark for +,*,/ and conversion to string
    ///
    /// The template version (only useful for Double and DecimalFP64, slower by ~40% than non template version)
    ///
    /// - Parameter start: the starting value for the calculations in the
    /// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
    static func genericFloatingPoint<T>(start: T) -> String where T:FloatingPoint, T:ExpressibleByFloatLiteral  {
        var s = start
        s /= T(10) // my value in sec
        s /= T(60) // my value in min
        var ret: String = ""
        for _ in 0...9999 {
            
            let ppm: T = 9.9
            
            let net = s * ppm
            let taxrate = T(19) / T(100)
            let tax = net * taxrate
            let gross = net + tax
            
            ret = "\(s), net: \(net), tax: \(tax), gross: \(gross)"
            s += 1.1
        }
        return ret
    }
}
