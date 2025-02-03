


enum TrackingStatus: String {
    
    case noData
    case inTransit
    case delivered
}



struct LaPosteTrackingData: Decodable {

    let shipment: Shipment
    
    struct Shipment: Decodable {
        
        let isFinal: Bool
    }
}
