
import Foundation



typealias TrackingNo = String



enum LaPosteTrackingStatus: String, Codable, IsOneOfAble, Sendable {
    
    case noData
    case inTransit
    case delivered
}



struct LaPosteTrackingClient {
    
    
    let debug: Debug
    
    
    init(_ debug: Debug) {
        
        self.debug = debug
    }
    
    
    func fetchTrackingStatus(forTrackingNo trackingNo: TrackingNo) async -> LaPosteTrackingStatus {
        
        let request = URLRequest(url: URL(string: "https://www.laposte.fr/ssu/sun/back/suivi-unifie/\(trackingNo)?lang=fr_FR")!)
        
        debug.printRequest(request)
        
        let (data, response) = try! await URLSession(configuration: .default).data(for: request)
        
        debug.printResponse(data, response)
        
        let decoder = JSONDecoder()
        
        if let successResponse = try? decoder.decode([TrackingData].self, from: data),
           let isFinal = successResponse.first?.shipment.isFinal {

            return isFinal ? .delivered : .inTransit
            
        } else {
            
            return .noData
        }
    }
    
    
    struct TrackingData: Decodable {

        let shipment: Shipment
        
        struct Shipment: Decodable {
            
            let isFinal: Bool
        }
    }
}
