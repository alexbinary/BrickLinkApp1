
import CoreBluetooth



extension CBManagerState: @retroactive CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        
        case .poweredOff: "poweredOff"
                
        case .poweredOn: "poweredOn"
        
        case .resetting: "resetting"
        
        case .unauthorized: "unauthorized"
        
        case .unknown: "unknown"
        
        case .unsupported: "unsupported"
        
        @unknown default: "unknown default"
        }
    }
}
