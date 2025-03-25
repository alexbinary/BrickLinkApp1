
import Foundation
import Core



enum BrickLinkUtility {
    
    
    static func url(forCatalogImageOfItemOfType type: BrickLinkItemType, ref: String, colorId: String) -> URL? {
        
        switch type {
        case .part:
            return URL(string: "https://img.bricklink.com/P/\(colorId)/\(ref).jpg")
        case .minifig:
            return URL(string: "https://img.bricklink.com/M/\(ref).jpg")
        }
    }
    
    
    static func url(forDetailsOfOrderWithId orderId: String) -> URL? {
        
        return URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(orderId)#/")
    }
    
    
    static func url(forInventoryItemWithId inventoryId: String) -> URL? {
        
        return URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(inventoryId)#/")
    }
}
