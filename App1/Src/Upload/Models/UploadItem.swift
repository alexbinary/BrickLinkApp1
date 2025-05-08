
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
    
    
    var itemIsValid: Bool {
        
        !ref.isEmpty && !(colorId ?? "").isEmpty && condition != nil
    }
}


extension UploadItem: PartDescriptible {
    
    
    var partDescriptor: PartDescriptor {
        .init(
            type: type,
            ref: ref,
            colorId: colorId,
            condition: condition
        )
    }
}
