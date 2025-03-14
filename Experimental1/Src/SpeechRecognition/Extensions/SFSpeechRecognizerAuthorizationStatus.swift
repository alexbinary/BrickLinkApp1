
import Speech



extension SFSpeechRecognizerAuthorizationStatus: @retroactive CustomStringConvertible {
    
    public var description: String {
        
        switch self {
            
        case .notDetermined:
            "notDetermined"
        
        case .denied:
            "denied"
        
        case .restricted:
            "restricted"
        
        case .authorized:
            "authorized"
        
        @unknown default:
            "unknown"
        }
    }
}
