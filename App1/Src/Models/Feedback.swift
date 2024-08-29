
import Foundation



struct Feedback: Identifiable {
    
    let id: Int
    let from: String
    let to: String
    let dateRated: Date
    let rating: Int
    let ratingOfBs: String
    let comment: String
}
