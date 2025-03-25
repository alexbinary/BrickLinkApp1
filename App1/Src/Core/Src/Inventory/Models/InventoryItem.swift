
import Foundation



public struct InventoryItem: Identifiable, Codable, Sendable {
    
    public let id: String
    public let condition: String
    public let colorId: String
    public let ref: String
    public let name: String
    public let type: BrickLinkItemType
    public let description: String
    public let remarks: String
    public let quantity: Int
    public let unitPrice: Float
    
    public init(
        id: String,
        condition: String,
        colorId: String,
        ref: String,
        name: String,
        type: BrickLinkItemType,
        description: String,
        remarks: String,
        quantity: Int,
        unitPrice: Float
    ) {
        self.id = id
        self.condition = condition
        self.colorId = colorId
        self.ref = ref
        self.name = name
        self.type = type
        self.description = description
        self.remarks = remarks
        self.quantity = quantity
        self.unitPrice = unitPrice
    }
}
