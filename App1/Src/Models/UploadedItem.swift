
import Foundation



struct UploadedItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: BrickLinkItemType
    let ref: String
    let name: String
    let colorId: LegoColor.ID
    let qty: Int
    let condition: String
    let comment: String
    let remarks: String
    let unitPrice: Float?
    let inventoryId: InventoryItem.ID
    let uploadDate: Date
}
