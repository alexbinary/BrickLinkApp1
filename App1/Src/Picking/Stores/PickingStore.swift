
import Foundation



class PickingStore {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        self.dataStore = dataStore
    }
    
    
    // MARK: - Pick
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.pickedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func pickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addPickedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unpickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removePickedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        unpickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.verifiedItemIdsByOrderId[orderId] ?? []
    }
    
    
    public func verifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addVerifiedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func verify(_ item: OrderItem) {
        
        verifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    public func unverifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removeVerifiedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
}
