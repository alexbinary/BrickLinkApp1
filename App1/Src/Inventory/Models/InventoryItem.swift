
import Foundation



struct InventoryItem: Identifiable, Codable {
    
    
    let id: String
    let condition: String
    let colorId: String
    let ref: String
    let name: String
    let type: ItemType
    let description: String
    let remarks: String
    let quantity: Int
    let unitPrice: Float
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
