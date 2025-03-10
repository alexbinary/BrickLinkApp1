
import Foundation



enum OrderMacroStatus: String, IsOneOfAble {
    
    
    case validatePayment
    case pickAndPack
    case ship
    case inTransit
    case inTransitFor30PlusDays
    case received
    case giveFeedback
    case recentlyClosed
    case closed
    
    
    var descriptionAndPicto: (picto: String, text: String) {
        
        switch self {
        
        case .validatePayment:
            (picto: "􁕍", text: "Validate payment")
        
        case .pickAndPack:
            (picto: "􀈥", text: "Pick and pack")

        case .ship:
            (picto: "􀐚", text: "Ship")

        case .inTransit:
            (picto: "􁁾", text: "In transit")
            
        case .inTransitFor30PlusDays:
            (picto: "􁁿", text: "In transit for 30+ days")

        case .received:
            (picto: "􀐛", text: "Received")
            
        case .giveFeedback:
            (picto: "􀉿", text: "Give feedback")

        case .recentlyClosed:
            (picto: "􀐫", text: "Recently closed")
        
        case .closed:
            (picto: "􀤟", text: "Closed")
        }
    }
        
    var descriptionWithPicto: String {
        
        let (picto, text) = descriptionAndPicto
        return "\(picto) \(text)"
    }
    
    
    var descriptionWithoutPicto: String {
        
        descriptionAndPicto.text
    }
}
