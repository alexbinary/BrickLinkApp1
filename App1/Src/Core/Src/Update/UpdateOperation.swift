
import Foundation



protocol UpdateOperation {
    
    var id: UUID { get }
    var operationTag: OperationTag? { get }
    var continuation: CheckedContinuation<(),Never> { get }
}


extension UpdateOperation {

    func resumeContinuation() {
        continuation.resume()
    }
}


// MARK: - Colors


struct LoadColorsOperation: UpdateOperation {
    
    let id = UUID()
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Inventory


struct LoadInventoriesOperation: UpdateOperation {
    
    let id = UUID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct LoadInventoryOperation: UpdateOperation {
    
    let id = UUID()
    let inventoryId: InventoryItem.ID
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Orders


struct LoadOrdersOperation: UpdateOperation {
    
    let id = UUID()
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderDetailsOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderItemsOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Order update


struct UpdateOrderStatusOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let status: OrderStatus
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct UpdateOrderTrackingNoOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let trackingNo: TrackingNo
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct SendDriveThruOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Tracking


struct UpdateLaPosteTrackingStatusOperation: UpdateOperation {
    
    let id = UUID()
    let trackingNo: TrackingNo
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Feedbacks


struct LoadOrderFeedbacksOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let refetchStrategy: RefetchStrategy
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}


struct PostOrderFeedbackOperation: UpdateOperation {
    
    let id = UUID()
    let order: Order
    let rating: FeedbackRating
    let comment: String
    let operationTag: OperationTag?
    let continuation: CheckedContinuation<(),Never>
}
