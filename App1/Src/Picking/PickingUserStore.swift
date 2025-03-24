
import Foundation



@Observable
class PickingUserStore {
    
    
    private let pickingStore: PickingStore
    
    
    init(_ pickingStore: PickingStore) {
        self.pickingStore = pickingStore
    }
    
    
    // MARK: - Pick
    
    
    public func pickedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        pickingStore.pickedOrderItems(forOrderWithId: orderId)
    }
    
    
    public func nextOrderItemsToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        pickingStore.nextOrderItemsToPick(forOrderWithId: orderId)
    }
    
    
    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingStore.pickingProgress(forOrderWithId: orderId)
    }
    
    
    public func totalLotsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        pickingStore.totalLotsLeftToPick(forOrderWithId: orderId)
    }
    
    
    public func totalPartsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        pickingStore.totalPartsLeftToPick(forOrderWithId: orderId)
    }
    
    
    public func pick(_ item: OrderItem) {
        
        pickingStore.pick(item)
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        pickingStore.unpick(item)
    }
    
    
    // MARK: - Verify
    
    
    public func verifiedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        pickingStore.verifiedOrderItems(forOrderWithId: orderId)
    }
    
    
    public func nextOrderItemsToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
    
        pickingStore.nextOrderItemsToVerify(forOrderWithId: orderId)
    }
    
    
    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        pickingStore.pickingVerificationProgress(forOrderWithId: orderId)
    }
    
    
    public func totalLotsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        pickingStore.totalLotsLeftToVerify(forOrderWithId: orderId)
    }
    
    
    public func totalPartsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        pickingStore.totalPartsLeftToVerify(forOrderWithId: orderId)
    }
    
    
    public func verify(_ item: OrderItem) {
        
        pickingStore.verify(item)
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        pickingStore.unverify(item)
    }
}
