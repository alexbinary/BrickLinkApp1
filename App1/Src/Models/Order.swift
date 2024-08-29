
import Foundation



struct Order: Identifiable {
    
    let id: String
    let date: Date
    let buyer: String
    let items: Int
    let lots: Int
    let grandTotal: Float
    let status: String
    let driveThruSent: Bool
    let trackingNo: String?
    let totalWeight: Float?
}
