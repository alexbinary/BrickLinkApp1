
import Foundation



typealias UpdateOperationID = UUID


protocol UpdateOperation {
    
    var id: UpdateOperationID { get }
    var operationTag: OperationTag? { get }
    var type: OperationType { get }
    var isWriteOperation: Bool { get }
    var isReadOperation: Bool { get }
    func isSame(as other: UpdateOperation) -> Bool
}


enum OperationType {
    
    case read
    case write
}


extension UpdateOperation {
    
    var type: OperationType {

        if self is UpdateInventoryOperation {
            return .write
        }
        if self is UpdateOrderStatusOperation {
            return .write
        }
        if self is UpdateOrderTrackingNoOperation {
            return .write
        }
        if self is SendDriveThruOperation {
            return .write
        }
        if self is PostOrderFeedbackOperation {
            return .write
        }
        return .read
    }

    var isWriteOperation: Bool {
        return type == .write
    }
    
    var isReadOperation: Bool {
        return type == .read
    }
}


// MARK: - Colors


struct LoadColorsOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        return other is LoadColorsOperation
    }
}


// MARK: - Inventory


struct LoadInventoriesOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        return other is LoadInventoriesOperation
    }
}


struct LoadInventoryOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let inventoryId: InventoryItem.ID
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? LoadInventoryOperation, otherOp.inventoryId == inventoryId {
            return true
        }
        return false
    }
}


struct UpdateInventoryOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let inventoryId: InventoryItem.ID
    let addQuantity: Int
    let unitPrice: Float?
    let remarks: String?
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? UpdateInventoryOperation {
            return otherOp.inventoryId == inventoryId && 
                   otherOp.addQuantity == addQuantity && 
                   otherOp.unitPrice == unitPrice && 
                   otherOp.remarks == remarks
        }
        return false
    }
}


// MARK: - Orders


struct LoadOrdersOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        return other is LoadOrdersOperation
    }
}


struct LoadOrderDetailsOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? LoadOrderDetailsOperation, otherOp.order.id == order.id {
            return true
        }
        return false
    }
}


struct LoadOrderItemsOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? LoadOrderItemsOperation, otherOp.order.id == order.id {
            return true
        }
        return false
    }
}


// MARK: - Order update


struct UpdateOrderStatusOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let status: OrderStatus
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? UpdateOrderStatusOperation {
            return otherOp.order.id == order.id && otherOp.status == status
        }
        return false
    }
}


struct UpdateOrderTrackingNoOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let trackingNo: TrackingNo
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? UpdateOrderTrackingNoOperation {
            return otherOp.order.id == order.id && otherOp.trackingNo == trackingNo
        }
        return false
    }
}


struct SendDriveThruOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? SendDriveThruOperation, otherOp.order.id == order.id {
            return true
        }
        return false
    }
}


// MARK: - Tracking


struct UpdateLaPosteTrackingStatusOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let trackingNo: TrackingNo
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? UpdateLaPosteTrackingStatusOperation, otherOp.trackingNo == trackingNo {
            return true
        }
        return false
    }
}


// MARK: - Feedbacks


struct LoadOrderFeedbacksOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? LoadOrderFeedbacksOperation, otherOp.order.id == order.id {
            return true
        }
        return false
    }
}


struct PostOrderFeedbackOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let rating: FeedbackRating
    let comment: String
    let operationTag: OperationTag?
    
    func isSame(as other: UpdateOperation) -> Bool {
        if let otherOp = other as? PostOrderFeedbackOperation {
            return otherOp.order.id == order.id && 
                   otherOp.rating == rating && 
                   otherOp.comment == comment
        }
        return false
    }
}
