
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



extension OrderItem {

    
    init(fromBl bl: BrickLinkOrderItem, orderId: String) {
        self.init(
            inventoryId: "\(bl.inventoryId)",
            orderId: orderId,
            condition: bl.newOrUsed,
            colorId: "\(bl.colorId)",
            colorName: bl.colorName,
            ref: bl.item.no,
            name: bl.item.name.htmlUnescape(),
            type: ItemType(fromBl: bl.item.type),
            location: bl.remarks ?? "",
            comment: (bl.description ?? "").htmlUnescape(),
            quantity: "\(bl.quantity)",
            unitPrice: bl.unitPrice.floatValue,
            unitPriceFinal: bl.unitPriceFinal.floatValue
        )
    }
}
