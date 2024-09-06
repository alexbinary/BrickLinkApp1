
import Foundation



struct Feedback: Identifiable, Codable {
    
    let id: Int
    let orderId: String
    let from: String
    let to: String
    let dateRated: Date
    let rating: Int
    let ratingOfBs: String
    let comment: String
}
