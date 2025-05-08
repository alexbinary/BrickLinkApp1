
import Foundation



struct OrderItem: Identifiable, Codable, Equatable {
    
    var id: InventoryItem.ID { inventoryId }
    
    let inventoryId: InventoryItem.ID
    let orderId: String
    let condition: ItemCondition
    let colorId: String
    let colorName: String
    let ref: String
    let name: String
    let type: ItemType
    let location: String
    let comment: String
    let quantity: String
    let unitPrice: Float
    let unitPriceFinal: Float
}


extension OrderItem: PartDescriptible {
    
    var partDescriptor: PartDescriptor {
        .init(
            item_type: type,
            item_ref: ref,
            item_colorId: colorId,
            item_condition: condition
        )
    }
}



extension OrderItem {

    
    init(fromBl bl: BrickLinkOrderItem, orderId: String) {
        self.init(
            inventoryId: "\(bl.inventoryId)",
            orderId: orderId,
            condition: .init(fromBl: bl.newOrUsed),
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
