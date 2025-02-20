


enum PaymentStatus: String, Codable, IsOneOfAble {
    
    case none = "None"
    case sent = "Sent"
    case received = "Received"
    case completed = "Completed"
}
