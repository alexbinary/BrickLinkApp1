
import Foundation



typealias UpdateOperationID = UUID


protocol UpdateOperation {
    
    var id: UpdateOperationID { get }
    var operationTag: OperationTag? { get }
    var type: OperationType { get }
    var isWriteOperation: Bool { get }
    var isReadOperation: Bool { get }
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
}


// MARK: - Inventory


struct LoadInventoriesOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


struct LoadInventoryOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let inventoryId: InventoryItem.ID
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


struct UpdateInventoryOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let inventoryId: InventoryItem.ID
    let addQuantity: Int
    let unitPrice: Float?
    let remarks: String?
    let operationTag: OperationTag?
}


// MARK: - Orders


struct LoadOrdersOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


struct LoadOrderDetailsOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


struct LoadOrderItemsOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


// MARK: - Order update


struct UpdateOrderStatusOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let status: OrderStatus
    let operationTag: OperationTag?
}


struct UpdateOrderTrackingNoOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let trackingNo: TrackingNo
    let operationTag: OperationTag?
}


struct SendDriveThruOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let operationTag: OperationTag?
}


// MARK: - Tracking


struct UpdateLaPosteTrackingStatusOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let trackingNo: TrackingNo
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


// MARK: - Feedbacks


struct LoadOrderFeedbacksOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
}


struct PostOrderFeedbackOperation: UpdateOperation {
    
    let id = UpdateOperationID()
    let order: Order
    let rating: FeedbackRating
    let comment: String
    let operationTag: OperationTag?
}
