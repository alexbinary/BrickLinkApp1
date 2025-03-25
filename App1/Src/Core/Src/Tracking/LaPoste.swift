
import Foundation



public enum LaPosteTrackingStatus: String, Codable, IsOneOfAble {
    
    case noData
    case inTransit
    case delivered
}



public struct LaPosteTrackingClient {
    
    
    let debug: Debug
    
    
    public init(_ debug: Debug) {
        
        self.debug = debug
    }
    
    
    public func fetchTrackingStatus(forTrackingNo trackingNo: String) async -> LaPosteTrackingStatus {
        
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
    
    
    public struct TrackingData: Decodable {

        public let shipment: Shipment
        
        public struct Shipment: Decodable {
            
            public let isFinal: Bool
        }
    }
}
