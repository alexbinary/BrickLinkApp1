
import Foundation



@Observable
class PickingController {
    
    
    private let orderDataAccess: OrderDataAccess
    private let pickingDataAccess: PickingDataAccess
    
    
    init(_ orderDataAccess: OrderDataAccess, _ pickingDataAccess: PickingDataAccess) {
        self.orderDataAccess = orderDataAccess
        self.pickingDataAccess = pickingDataAccess
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderDataAccess.orderItems(forOrderWithId: orderId)
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID, fromItemIds itemsIds: [OrderItem.ID]) -> [OrderItem] {
        
        orderDataAccess.orderItems(forOrderWithId: orderId, fromItemIds: itemsIds)
    }
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingDataAccess.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingDataAccess.verifiedItemIds(forOrderWithId: orderId)
    }
    
    
    // MARK: - Pick
    
    
    public func pick(_ item: OrderItem) {
        
        pickingDataAccess.pick(item)
    }
    
    
    public func unpick(_ item: OrderItem) {
        
        pickingDataAccess.unpick(item)
    }
    
    
    public func pickingProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let picked = pickedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(picked)/Double(total))
    }
    
    
    public func orderItemsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId).filter { !pickedIds.contains($0.id) }
    }
    
    
    public func totalLotsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToPick(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToPick(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func nextOrderItemsToPick(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { !pickedIds.contains($0.id) }
            .sorted { $0.location < $1.location }
    }
    
    
    public func pickedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: pickedIds).reversed()
    }
    
    
    // MARK: - Verify
    
    
    public func verify(_ item: OrderItem) {
        
        pickingDataAccess.verify(item)
    }
    
    
    public func unverify(_ item: OrderItem) {
        
        pickingDataAccess.unverify(item)
    }
    

    public func pickingVerificationProgress(forOrderWithId orderId: OrderSummary.ID) -> Percent {
        
        let total = orderItems(forOrderWithId: orderId).count
        let verified = verifiedItemIds(forOrderWithId: orderId).count
        
        return Percent(Double(verified)/Double(total))
    }
    
    
    public func orderItemsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId).filter { !verifiedIds.contains($0.id) }
    }
    
    
    public func totalLotsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).count
    }
    
    
    public func totalPartsLeftToVerify(forOrderWithId orderId: OrderSummary.ID) -> Int {
        
        orderItemsLeftToVerify(forOrderWithId: orderId).reduce(0) { $0 + Int($1.quantity)! }
    }
    
    
    public func nextOrderItemsToVerify(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
    
        let pickedIds = pickedItemIds(forOrderWithId: orderId)
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId)
            .filter { pickedIds.contains($0.id) && !verifiedIds.contains($0.id) }
            .sorted { a, b in a.condition == "N" }
    }
    
    
    public func verifiedOrderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        let verifiedIds = verifiedItemIds(forOrderWithId: orderId)
        
        return orderItems(forOrderWithId: orderId, fromItemIds: verifiedIds).reversed()
    }
}
