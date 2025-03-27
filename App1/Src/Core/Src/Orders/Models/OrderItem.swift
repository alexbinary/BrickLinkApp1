
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
    public let type: ItemType
    public let location: String
    public let comment: String
    public let quantity: String
    public let unitPrice: Float
    public let unitPriceFinal: Float
}
