
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



extension InventoryItem {

    
    init(fromBl bl: BrickLinkInventoryItem) {
        self.init(
            id: "\(bl.inventoryId)",
            condition: bl.newOrUsed,
            colorId: "\(bl.colorId)",
            ref: bl.item.no,
            name: bl.item.name,
            type: ItemType(fromBl: bl.item.type),
            description: bl.description ?? "",
            remarks: bl.remarks ?? "",
            quantity: bl.quantity,
            unitPrice: bl.unitPrice.floatValue
        )
    }
}
