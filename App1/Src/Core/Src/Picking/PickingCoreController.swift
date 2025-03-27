
import Foundation



@MainActor
class PickingCoreController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Pick
    
    
    func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.pickedItemIdsByOrderId[orderId] ?? []
    }
    
    
    func pickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addPickedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func pick(_ item: OrderItem) {
        
        pickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    func unpickItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removePickedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func unpick(_ item: OrderItem) {
        
        unpickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    // MARK: - Verify
    
    
    func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        return dataStore.verifiedItemIdsByOrderId[orderId] ?? []
    }
    
    
    func verifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addVerifiedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func verify(_ item: OrderItem) {
        
        verifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    func unverifyItem(forOrderWithId orderId: OrderSummary.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removeVerifiedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func unverify(_ item: OrderItem) {
        
        unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
}
