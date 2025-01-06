
import Foundation



enum OrderBusinessStatus: String, IsOneOfAble {
    
    
    case validatePayment
    case pickAndPack
    case ship
    case inTransit
    case giveFeedback
    case done
    case closed
    
    
    var descriptionWithPicto: String {
        
        switch self {
        
        case .validatePayment:
            "􁕍 Validate payment"
        
        case .pickAndPack:
            "􀈥 Pick and pack"
        
        case .ship:
            "􀐚 Ship"
        
        case .inTransit:
            "􁁾 In transit"
        
        case .giveFeedback:
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
