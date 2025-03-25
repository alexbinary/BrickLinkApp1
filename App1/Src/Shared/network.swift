
import Foundation



struct Debug {
    
    let printRequest: Bool
    let printResponse: Bool
    
    
    func printRequest(_ request: URLRequest) {
        
        if printRequest {
            print(request.url!.absoluteString)
            if let body = request.httpBody {
                print(String(data: body, encoding: .utf8)!)
            }
        }
    }
    
    
    func printResponse(_ data: Data, _ response: URLResponse) {
        
        if printResponse {
            print(String(data: data, encoding: .utf8)!)
        }
    }
}
