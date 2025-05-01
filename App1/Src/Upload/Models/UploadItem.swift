import Foundation



struct UploadItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: ItemType
    let ref: String
    let name: String?
    let colorId: LegoColor.ID
    let qty: Int?
    let condition: ItemCondition?
    let comment: String?
    let unitPrice: Float?
}


extension UploadItem: PartIdentity {
    
    var item_type: ItemType? { type }
    var item_ref: String? { ref }
    var item_colorId: String? { colorId }
    var item_condition: ItemCondition? { condition }
}
