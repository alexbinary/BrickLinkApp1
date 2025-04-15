


enum PaymentStatus: String, Codable, IsOneOfAble, Sendable {
    
    case none = "None"
    case sent = "Sent"
    case received = "Received"
    case completed = "Completed"
}
