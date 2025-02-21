
import Foundation



enum LaPosteTrackingStatus: String, Codable {
    
    case noData
    case inTransit
    case delivered
}



struct LaPosteTrackingClient {
    
    
    static func fetchTrackingStatus(forTrackingNo trackingNo: String) async -> LaPosteTrackingStatus {
        
        let request = URLRequest(url: URL(string: "https://www.laposte.fr/ssu/sun/back/suivi-unifie/\(trackingNo)?lang=fr_FR")!)
        
        let (data, _) = try! await URLSession(configuration: .default).data(for: request)
        print(String(data: data, encoding: .utf8)!)
        
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
