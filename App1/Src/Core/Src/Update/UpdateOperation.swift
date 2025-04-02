
import Foundation



protocol UpdateOperation {
    
    var continuation: CheckedContinuation<(),Never> { get }
}


extension UpdateOperation {
    
    func resumeContinuation() {
        continuation.resume()
    }
}


// MARK: - Colors


struct LoadColorsOperation: UpdateOperation {
    
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Inventory


struct LoadInventoriesOperation: UpdateOperation {
    
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadInventoryOperation: UpdateOperation {
    
    let inventoryId: InventoryItem.ID
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Orders


struct LoadOrdersOperation: UpdateOperation {
    
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderDetailsOperation: UpdateOperation {
    
    let order: Order
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderItemsOperation: UpdateOperation {
    
    let order: Order
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Order update


struct UpdateOrderStatusOperation: UpdateOperation {
    
    let order: Order
    let status: OrderStatus
    let continuation: CheckedContinuation<(),Never>
}


struct UpdateOrderTrackingNoOperation: UpdateOperation {
    
    let order: Order
    let trackingNo: TrackingNo
    let continuation: CheckedContinuation<(),Never>
}


struct SendDriveThruOperation: UpdateOperation {
    
    let order: Order
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Tracking


struct UpdateLaPosteTrackingStatusOperation: UpdateOperation {
    
    let trackingNo: TrackingNo
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Feedbacks


struct LoadOrderFeedbacksOperation: UpdateOperation {
    
    let order: Order
    let refetchStrategy: RefetchStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct PostOrderFeedbackOperation: UpdateOperation {
    
    let order: Order
    let rating: FeedbackRating
    let comment: String
    let continuation: CheckedContinuation<(),Never>
}
