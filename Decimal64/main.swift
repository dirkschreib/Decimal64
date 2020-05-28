//
//  main.swift
//  Decimal64
//
//  Created by Dirk on 18.07.19.
//  Copyright © 2019 Dirk Schreib. All rights reserved.
//

import Foundation

/// This is a small benchmark for +,*,/ and conversion to string
///
/// The template version (only useful for Double and DecimalFP64, slower by ~40% than non template version)
///
/// - Parameter start: the starting value for the calculations in the
/// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
func templTest<T>( start: T ) -> String where T: FloatingPoint, T: ExpressibleByFloatLiteral  {
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

/// This is a small benchmark for +,*,/ and conversion to string
/// Version for builtin Double (64bit)
///
/// - Parameter start: the starting value for the calculations in the
/// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
func testDouble( start: Double ) -> String  {
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

/// This is a small benchmark for +,*,/ and conversion to string
/// Version for builtin Decimal (160bit)
///
/// - Parameter start: the starting value for the calculations in the
/// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
func testDecimal( start: Decimal ) -> String  {
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

/// This is a small benchmark for +,*,/ and conversion to string
/// Version for DecimalFP64 (64bit) which conforms to the FloatingPoint protocol
///
/// - Parameter start: the starting value for the calculations in the
/// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
func testDecimalFP64( start: DecimalFP64 ) -> String  {
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

/// This is a small benchmark for +,*,/ and conversion to string
/// Version for Decimal64 (64bit) which does NOT conforms to the FloatingPoint protocol
///
/// - Parameter start: the starting value for the calculations in the
/// - Returns: A string result of the numbers (to compare results and to make sure that the string conversion is not optimized away)
func testDecimal64( start: Decimal64 ) -> String  {
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

extension BinaryInteger {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = self
        var counter = 0

        for _ in (1...self.bitWidth) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }
        return binaryString
    }
}


extension Decimal64 {
    var binaryDescription: String {
        var binaryString = ""
        var internalNumber = Int64(exponent)
        var counter = 0

        for _ in (1...Decimal64.EXP_SIZE) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }
        binaryString.insert(contentsOf: " e ", at: binaryString.startIndex)

        internalNumber = mantissa
        counter = 0

        for _ in (1...Decimal64.MAN_SIZE) {
            binaryString.insert(contentsOf: "\(internalNumber & 1)", at: binaryString.startIndex)
            internalNumber >>= 1
            counter += 1
            if counter % 4 == 0 || counter == 54 {
                binaryString.insert(contentsOf: " ", at: binaryString.startIndex)
            }
        }

        return binaryString
    }
}
print("Hello performance!")
var s: String

var date = Date()
for i in 1...100 {
    s = testDouble(start: Double(Double(i)/10))
}
print("Double  time: ", date.timeIntervalSinceNow)
date = Date()
for i in 1...100 {
    s = testDecimal(start: Decimal(Double(i)/10))
}
print("Decimal time: ", date.timeIntervalSinceNow)
date = Date()
for i in 1...100 {
    s = testDecimalFP64(start: DecimalFP64(Double(i)/10))
}
print("DecFP64 time: ", date.timeIntervalSinceNow)
date = Date()
for i in 1...100 {
    s = testDecimal64(start: Decimal64(Double(i)/10)!)
}
print("Dec64   time: ", date.timeIntervalSinceNow)

date = Date()
for i in 1...100 {
    s = templTest(start: Double(Double(i)/10))
}
print("TDouble time: ", date.timeIntervalSinceNow)
date = Date()
for i in 1...100 {
    s = templTest(start: DecimalFP64(Double(i)/10))
}
print("TDec64FPtime: ", date.timeIntervalSinceNow)

