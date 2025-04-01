
import Foundation



protocol UpdateOperation {
    
    var continuation: CheckedContinuation<(),Never> { get }
}


extension UpdateOperation {
    
    func resumeContinuation() {
        continuation.resume()
    }
}


protocol RefreshOperation: UpdateOperation {
    
    var strategy: LoadStrategy { get }
}


// MARK: - Colors


struct LoadColorsOperation: RefreshOperation {
    
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Inventory


struct LoadInventoriesOperation: RefreshOperation {
    
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadInventoryOperation: RefreshOperation {
    
    let inventoryId: InventoryItem.ID
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Orders


struct LoadOrdersOperation: RefreshOperation {
    
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderDetailsOperation: RefreshOperation {
    
    let order: Order
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct LoadOrderItemsOperation: RefreshOperation {
    
    let order: Order
    let strategy: LoadStrategy
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
    let trackingNo: String
    let continuation: CheckedContinuation<(),Never>
}


struct SendDriveThruOperation: UpdateOperation {
    
    let order: Order
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Tracking


struct UpdateLaPosteTrackingStatusOperation: RefreshOperation {
    
    let trackingNo: String
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


// MARK: - Feedbacks


struct LoadOrderFeedbacksOperation: RefreshOperation {
    
    let order: Order
    let strategy: LoadStrategy
    let continuation: CheckedContinuation<(),Never>
}


struct PostOrderFeedbackOperation: UpdateOperation {
    
    let order: Order
    let rating: FeedbackRating
    let comment: String
    let continuation: CheckedContinuation<(),Never>
}
