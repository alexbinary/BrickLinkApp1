import Foundation



struct UploadItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: ItemType
    let ref: String
    let name: String?
    let colorId: LegoColor.ID
    let qty: Int?
    let condition: String?
    let comment: String?
    let unitPrice: Float?
}


extension UploadItem: PartIdentity {
    
    var item_ref: String? { ref }
    var item_condition: String? { condition }
}
