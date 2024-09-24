
import Foundation



struct InventoryItem: Identifiable {
    
    let id: String
    let condition: String
    let colorId: String
    let ref: String
    let name: String
    let type: BrickLinkItemType
    let description: String
    let remarks: String
    let quantity: Int
    let unitPrice: Float
}
