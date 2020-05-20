import Decimals
import Foundation

var (start, stop, result) = (DispatchTime.now(), DispatchTime.now(), String())
print()

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.double(start: Double(Double(i)/10))
}
stop = DispatchTime.now()
print("Swift.Double:             ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.decimal(start: Decimal(Double(i)/10))
}
stop = DispatchTime.now()
print("Foundation.Decimal:       ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.decimalFP64(start: DecimalFP64(Double(i)/10))
}
stop = DispatchTime.now()
print("Decimals.DecimalFP64:     ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.decimal64(start: Decimal64(Double(i)/10)!)
}
stop = DispatchTime.now()
print("Decimals.Decimal64:       ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

print()

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.genericFloatingPoint(start: Double(Double(i)/10))
}
stop = DispatchTime.now()
print("Swift.Double (G):         ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

start = DispatchTime.now()
for i in 1...100 {
    result = Benchmark.genericFloatingPoint(start: DecimalFP64(Double(i)/10))
}
stop = DispatchTime.now()
print("Decimals.DecimalFP64 (G): ", stop.uptimeNanoseconds - start.uptimeNanoseconds)

print()
