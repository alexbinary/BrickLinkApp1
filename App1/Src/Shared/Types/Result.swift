
import Foundation



enum Result<T> {
    
    case loading
    case notFound
    case found(T)
}
