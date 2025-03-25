
import Foundation



public struct UploadItem: Identifiable, Codable, Equatable {
    
    public var id = UUID()
    public let type: BrickLinkItemType
    public let ref: String
    public let name: String?
    public let colorId: LegoColor.ID
    public let qty: Int?
    public let condition: String?
    public let comment: String?
    public let unitPrice: Float?
    
    public init(id: UUID = UUID(), type: BrickLinkItemType, ref: String, name: String?, colorId: LegoColor.ID, qty: Int?, condition: String?, comment: String?, unitPrice: Float?) {
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
