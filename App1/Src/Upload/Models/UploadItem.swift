
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
    
    init(id: UUID = UUID(), type: ItemType, ref: String, name: String?, colorId: LegoColor.ID, qty: Int?, condition: String?, comment: String?, unitPrice: Float?) {
        self.id = id
        self.type = type
        self.ref = ref
        self.name = name
        self.colorId = colorId
        self.qty = qty
        self.condition = condition
        self.comment = comment
        self.unitPrice = unitPrice
    }
}
