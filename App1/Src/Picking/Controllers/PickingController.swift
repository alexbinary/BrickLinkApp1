
import Foundation



class PickingController {
    
    
    private let dataStore: DataStore
    
    
    init(_ dataStore: DataStore) {
        
        self.dataStore = dataStore
    }
    
    
    // MARK: - Pick
    
    
    func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickedItemIds(forOrderWithId: order.id)
    }
    
    
    //
    func pickedItemIds(forOrderWithId orderId: Order.ID) -> [OrderItem.ID] {
        
        return dataStore.pickedItemIdsByOrderId[orderId] ?? []
    }
    
    
    func pickItem(for order: Order, itemId: OrderItem.ID) {
        
        pickItem(forOrderWithId: order.id, itemId: itemId)
    }
    
    
    func pickItem(forOrderWithId orderId: Order.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addPickedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func pick(_ item: OrderItem) {
        
        pickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    func unpickItem(for order: Order, itemId: OrderItem.ID) {
        
        unpickItem(forOrderWithId: order.id, itemId: itemId)
    }
    
    
    func unpickItem(forOrderWithId orderId: Order.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removePickedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func unpick(_ item: OrderItem) {
        
        unpickItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    // MARK: - Verify
    
    
    func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        return dataStore.verifiedItemIdsByOrderId[order.id] ?? []
    }
    
    
    func verifyItem(for order: Order, itemId: OrderItem.ID) {
        
        verifyItem(forOrderWithId: order.id, itemId: itemId)
    }
    
    
    func verifyItem(forOrderWithId orderId: Order.ID, itemId: OrderItem.ID) {
        
        try! dataStore.addVerifiedItemId(itemId, toOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func verify(_ item: OrderItem) {
        
        verifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
    
    
    func unverifyItem(for order: Order, itemId: OrderItem.ID) {
        
        unverifyItem(forOrderWithId: order.id, itemId: itemId)
    }
    
    
    func unverifyItem(forOrderWithId orderId: Order.ID, itemId: OrderItem.ID) {
        
        try! dataStore.removeVerifiedItemId(itemId, fromOrderWithId: orderId)
        try! dataStore.save()
    }
    
    
    func unverify(_ item: OrderItem) {
        
        unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
    }
}
