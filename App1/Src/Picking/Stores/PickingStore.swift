
import Foundation



class PickingStore {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    // MARK: - Pick
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return fileDataAccess.pickedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func pickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! fileDataAccess.addPickedItemId(itemId, toOrderWithId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unpickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! fileDataAccess.removePickedItemId(itemId, fromOrderWithId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        unpickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return fileDataAccess.verifiedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func verifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! fileDataAccess.addVerifiedItemId(itemId, toOrderWithId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func verify(_ item: OrderItem) {
        
        verifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unverifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! fileDataAccess.removeVerifiedItemId(itemId, fromOrderWithId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
}
