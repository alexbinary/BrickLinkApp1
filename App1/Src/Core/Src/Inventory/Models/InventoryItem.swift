
import Foundation



public struct InventoryItem: Identifiable, Codable, Sendable {
    
    public let id: String
    public let condition: String
    public let colorId: String
    public let ref: String
    public let name: String
    public let type: ItemType
    public let description: String
    public let remarks: String
    public let quantity: Int
    public let unitPrice: Float
}
