
import SwiftUI


class AppController: ObservableObject {
    
    
    func shippingCost(forOrderWithId id: String) -> Int {
        
        switch id {
        case "#1":
            return 12
        case "#2":
            return 56
        default:
            return 0
        }
    }
}
