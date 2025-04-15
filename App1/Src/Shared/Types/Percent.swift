
import Foundation



struct Percent {

    var fractionValue: Double

    init(_ value: Double) {
		self.fractionValue = value
	}
}


postfix operator %

postfix func %(value: Double) -> Percent {
    Percent(value/100)
}


extension Percent: CustomStringConvertible {

    var description: String {
        String(format: "%3.0f%%", fractionValue*100)
    }
}


func *(lhs: CGFloat, rhs: Percent) -> CGFloat {
    lhs * rhs.fractionValue
}


extension Percent: Comparable {

    static func < (lhs: Percent, rhs: Percent) -> Bool {
        lhs.fractionValue < rhs.fractionValue
	}
}
