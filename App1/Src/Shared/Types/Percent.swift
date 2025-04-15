
import Foundation



public struct Percent {

    public var fractionValue: Double

    public init(_ value: Double) {
		self.fractionValue = value
	}
}


postfix operator %

public postfix func %(value: Double) -> Percent {
    Percent(value/100)
}


extension Percent: CustomStringConvertible {

    public var description: String {
        String(format: "%3.0f%%", fractionValue*100)
    }
}


public func *(lhs: CGFloat, rhs: Percent) -> CGFloat {
    lhs * rhs.fractionValue
}


extension Percent: Comparable {

    public static func < (lhs: Percent, rhs: Percent) -> Bool {
        lhs.fractionValue < rhs.fractionValue
	}
}
