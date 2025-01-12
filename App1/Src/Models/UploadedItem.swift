
import Foundation



struct UploadedItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: BrickLinkItemType
    let ref: String
    let name: String
    let colorId: LegoColor.ID
    let qtyBefore: Int?
    let qtyAfter: Int
    let condition: String
    let comment: String?
    let remarksBefore: String?
    let remarksAfter: String
    let unitPriceBefore: Float?
    let unitPriceAfter: Float
    let inventoryId: InventoryItem.ID
    let uploadDate: Date
}
