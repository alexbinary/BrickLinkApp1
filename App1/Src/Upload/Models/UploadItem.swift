
import Foundation



struct UploadItem: Identifiable, Codable, Equatable {
    
    
    var id = UUID()
    let type: ItemType
    let ref: String
    let name: String?
    let colorId: LegoColor.ID?
    let qty: Int?
    let condition: ItemCondition?
    let comment: String?
    let unitPrice: Float?
    
    
    var partDescriptor: PartDescriptor {
        .init(
            item_type: type,
            item_ref: ref,
            item_colorId: colorId,
            item_condition: condition
        )
    }
    
    
    var itemIsValid: Bool {
        
        ref.isEmpty && !(colorId ?? "").isEmpty && condition != nil
    }
}
