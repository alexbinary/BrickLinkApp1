


struct PreviewPickingStore: PickingStoreProtocol {
    
    
    func pickedOrderItems(for order: Order) -> [OrderItem] {
        
        return []
    }
    
    func nextOrderItemsToPick(for order: Order) -> [OrderItem] {
        
        return [
            .init(
                inventoryId: "",
                orderId: "",
                condition: "U",
                colorId: "",
                colorName: "",
                ref: "",
                name: "",
                type: .part,
                location: "",
                comment: "",
                quantity: "42",
                unitPrice: 0,
                unitPriceFinal: 0
            )
        ]
    }
    
    func pickingProgress(for order: Order) -> Percent {
        
        return 42%
    }
    
    func totalPartsLeftToPick(for order: Order) -> Int {
        
        return 42
    }
    
    func totalLotsLeftToPick(for order: Order) -> Int {
        
        return 42
    }
    
    func pick(_ item: OrderItem) {
        
    }
    
    func unpick(_ item: OrderItem) {
        
    }
    
    func verifiedOrderItems(for order: Order) -> [OrderItem] {
        
        return []
    }
    
    func nextOrderItemsToVerify(for order: Order) -> [OrderItem] {
        
        return []
    }
    
    func pickingVerificationProgress(for order: Order) -> Percent {
        
        return 42%
    }
    
    func totalPartsLeftToVerify(for order: Order) -> Int {
        
        return 42
    }
    
    func totalLotsLeftToVerify(for order: Order) -> Int {
        
        return 42
    }
    
    func verify(_ item: OrderItem) {
        
    }
    
    func unverify(_ item: OrderItem) {
        
    }
}
