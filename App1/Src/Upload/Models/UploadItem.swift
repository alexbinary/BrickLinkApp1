
import Foundation



struct UploadItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: BrickLinkItemType
    let ref: String
    let name: String?
    let colorId: LegoColor.ID
    let qty: Int?
    let condition: String?
    let comment: String?
    let unitPrice: Float?
}
