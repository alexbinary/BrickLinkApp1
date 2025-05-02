
import Foundation



struct ValidatedValue<T> {
    
    var submitValue: T? = nil
    var isInvalid: Bool = false
    var isValid: Bool { !isInvalid }
    var hasChanges: Bool = false
}
