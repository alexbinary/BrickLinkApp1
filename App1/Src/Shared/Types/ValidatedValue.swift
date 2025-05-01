
import Foundation



struct ValidatedValue<T> {
    
    var valueToSubmit: T? = nil
    var hasWarning: Bool = false
}
