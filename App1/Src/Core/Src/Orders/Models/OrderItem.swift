
import Foundation



public struct OrderItem: Identifiable, Codable {
    
    public var id: InventoryItem.ID { inventoryId }
    
    public let inventoryId: InventoryItem.ID
    public let orderId: String
    public let condition: String
    public let colorId: String
    public let colorName: String
    public let ref: String
    public let name: String
    public let type: BrickLinkItemType
    public let location: String
    public let comment: String
    public let quantity: String
    public let unitPrice: Float
    public let unitPriceFinal: Float
    
    public init(inventoryId: InventoryItem.ID, orderId: String, condition: String, colorId: String, colorName: String, ref: String, name: String, type: BrickLinkItemType, location: String, comment: String, quantity: String, unitPrice: Float, unitPriceFinal: Float) {
        self.inventoryId = inventoryId
        self.orderId = orderId
        self.condition = condition
        self.colorId = colorId
        self.colorName = colorName
        self.ref = ref
        self.name = name
        self.type = type
        self.location = location
        self.comment = comment
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.unitPriceFinal = unitPriceFinal
    }
}
