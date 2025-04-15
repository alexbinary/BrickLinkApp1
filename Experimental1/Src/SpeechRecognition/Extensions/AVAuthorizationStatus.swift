
import AVFoundation



extension AVAuthorizationStatus: @retroactive CustomStringConvertible {
    
    var description: String {
        
        switch self {
            
        case .notDetermined:
            "notDetermined"
            
        case .restricted:
            "restricted"
            
        case .denied:
            "denied"
            
        case .authorized:
            "authorized"
            
        @unknown default:
            "unknown"
        }
    }
}
