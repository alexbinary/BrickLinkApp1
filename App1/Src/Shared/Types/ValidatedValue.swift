
import Foundation



struct ValidatedValue<T> {
    
    var submitValue: T? = nil
    
    var validity: Validity
    var isValid: Bool { validity == .valid }
    var isInvalid: Bool { validity == .invalid }
    
    var hasWarning: Bool = false
    var hasChanges: Bool = false
}


enum Validity {
    
    case valid
    case invalid
    case indeterminate
}
