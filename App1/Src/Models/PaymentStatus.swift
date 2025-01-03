


enum PaymentStatus: String, Codable {
    
    case none = "None"
    case sent = "Sent"
    case received = "Received"
    case completed = "Completed"
}



extension PaymentStatus {
    
    
    func isOneOf(_ arr: [PaymentStatus]) -> Bool {
        
        arr.contains(self)
    }
    
    
    func isNotOneOf(_ arr: [PaymentStatus]) -> Bool {
        
        !self.isOneOf(arr)
    }
}
