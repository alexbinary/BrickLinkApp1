
import Foundation



public struct Debug {
    
    public let printRequest: Bool
    public let printResponse: Bool
    
    public init(printRequest: Bool, printResponse: Bool) {
     
        self.printRequest = printRequest
        self.printResponse = printResponse
    }
    
    
    public func printRequest(_ request: URLRequest) {
        
        if printRequest {
            print(request.url!.absoluteString)
            if let body = request.httpBody {
                print(String(data: body, encoding: .utf8)!)
            }
        }
    }
    
    
    public func printResponse(_ data: Data, _ response: URLResponse) {
        
        if printResponse {
            print(String(data: data, encoding: .utf8)!)
        }
    }
}
