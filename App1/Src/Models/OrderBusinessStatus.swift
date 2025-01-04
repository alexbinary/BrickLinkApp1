
import Foundation



enum OrderBusinessStatus: String, IsOneOfAble {
    
    
    case pendingPayment
    case validatePayment
    case readyForPicking
    case readyToShip
    case validateShipping
    case inTransit
    case received
    case done
    case closed
    
    
    var descriptionWithPicto: String {
        
        switch self {
        
        case .pendingPayment:
            "􀖧 Pending payment"
        
        case .validatePayment:
            "􁕍 Validate payment"
        
        case .readyForPicking:
            "􀈥 Ready to pick"
        
        case .readyToShip:
            "􀐚 Ready to ship"
        
        case .validateShipping:
            "􁕍 Validate shipping"
        
        case .inTransit:
            "􁁾 In transit"
        
        case .received:
            "􀐛 Received"
        
        case .done:
            "􁙕 Done"
        
        case .closed:
            "􀤟 Closed"
        }
    }
    
    
    var descriptionWithoutPicto: String {
        
        let sep = " "
        let parts = self.descriptionWithPicto.split(separator: sep)
        return parts.dropFirst().joined(separator: sep)
    }
}
