
import Foundation



enum Debug {
    
    static let printRequest = Secrets.Network.printRequest
    static let printResponse = Secrets.Network.printResponse
    
    
    static func printRequest(_ request: URLRequest) {
        
        if printRequest {
            print(request.url!.absoluteString)
            if let body = request.httpBody {
                print(String(data: body, encoding: .utf8)!)
            }
        }
    }
    
    
    static func printResponse(_ data: Data, _ response: URLResponse) {
        
        if printResponse {
            print(String(data: data, encoding: .utf8)!)
        }
    }
}
