
import Foundation



struct UploadItem: Identifiable, Codable {
    
    var id = UUID()
    let type: BrickLinkItemType
    let ref: String
    let colorId: LegoColor.ID
    let qty: Int
    let condition: String
    let comment: String
    let remarks: String?
    let unitPrice: Float?
}
