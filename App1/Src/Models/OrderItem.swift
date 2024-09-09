
import Foundation



struct OrderItem: Identifiable, Codable {
    
    var id: InventoryItem.ID { inventoryId }
    
    let inventoryId: InventoryItem.ID
    let orderId: String
    let condition: String
    let colorId: String
    let colorName: String
    let ref: String
    let name: String
    let type: BrickLinkItemType
    let location: String
    let comment: String
    let quantity: String
    let quantityLeft: String
    let unitPrice: Float
    let unitPriceFinal: Float
}
