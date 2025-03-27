
import Foundation



@Observable
@MainActor
class OrderChecklistCoreController {
    
    
    private let orderCoreController: OrderCoreController
    private let pickingCoreController: PickingCoreController
    private let shippingCoreController: ShippingCoreController
    private let feedbackCoreController: FeedbackCoreController
    private let transactionCoreController: TransactionCoreController
    private let trackingMiddleController: TrackingMiddleController
    private let pickingProgressCoreController: PickingProgressCoreController
    
    
    init(
        _ orderCoreController: OrderCoreController,
        _ pickingCoreController: PickingCoreController,
        _ shippingCoreController: ShippingCoreController,
        _ feedbackCoreController: FeedbackCoreController,
        _ transactionCoreController: TransactionCoreController,
        _ trackingMiddleController: TrackingMiddleController,
        _ pickingProgressCoreController: PickingProgressCoreController
    ) {
        self.orderCoreController = orderCoreController
        self.pickingCoreController = pickingCoreController
        self.shippingCoreController = shippingCoreController
        self.feedbackCoreController = feedbackCoreController
        self.transactionCoreController = transactionCoreController
        self.trackingMiddleController = trackingMiddleController
        self.pickingProgressCoreController = pickingProgressCoreController
    }
    
    
    func orderSummary(forOrderWithId orderId: Order.ID) -> Order? {
        
        orderCoreController.orderSummary(forOrderWithId: orderId)
    }
    
    
    func orderIsValidatedWithoutIncomeTransaction(orderId: Order.ID) -> Bool {
        
        transactionCoreController.orderIsValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    func incomeTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        transactionCoreController.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    func shippingTransactions(forOrderWithId orderId: Order.ID) -> [Transaction] {
        
        transactionCoreController.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    func orderIsValidatedWithoutShippingTransaction(orderId: Order.ID) -> Bool {
        
        transactionCoreController.orderIsValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    func orderDetails(forOrderWithId orderId: Order.ID) -> OrderDetails? {
        
        orderCoreController.orderDetails(forOrderWithId: orderId)
    }
    
    
    func stamping(forOrderWithId orderId: Order.ID) -> String? {
        
        shippingCoreController.confirmedStamping(forOrderWithId: orderId)
    }
    
    
    func orderIsValidatedWithoutStamping(orderId: Order.ID) -> Bool {
        
        shippingCoreController.orderIsValidatedWithoutStamping(orderId: orderId)
    }
    
    
    func orderItems(forOrderWithId orderId: Order.ID) -> [OrderItem] {
        
        orderCoreController.orderItems(forOrderWithId: orderId)
    }
    
    
    func pickedItemIds(forOrderWithId orderId: Order.ID) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    func verifiedItemIds(forOrderWithId orderId: Order.ID) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(forOrderWithId: orderId)
    }
    
    
    func orderFeedbacks(forOrderWithId orderId: Order.ID) -> [Feedback] {
        
        feedbackCoreController.feedbacks(forOrderWithId: orderId)
    }
    
    
    func orderIsValidatedWithoutFeedback(orderId: Order.ID) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    // -
    
    
    func orderChecklistPayment(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    func orderChecklistIncomeTransaction(_ orderId: Order.ID) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(orderId: orderId) {
            return true
        }
        return !incomeTransactions(forOrderWithId: orderId).isEmpty
    }
    
    
    func orderChecklistShippingTransaction(_ orderId: Order.ID) -> Bool {
        
        if !shippingTransactions(forOrderWithId: orderId).isEmpty {
            
            return true
        }
        
        if orderIsValidatedWithoutShippingTransaction(orderId: orderId) {
            
            return true
        }
        
        let order = orderDetails(forOrderWithId: orderId)!
        if order.shippingMethodId.isOneOf(shippingMethodIds_LaPoste) {
        
            let stamping = stamping(forOrderWithId: orderId)
            if !(stamping ?? "").isEmpty, stamping != "Bureau de poste" {
                
                return true
            }
        }
        
        return false
    }
    
    
    func orderChecklistPicking(_ orderId: Order.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let pickedItemIds = pickedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { pickedItemIds.contains($0.id) }
    }
    
    
    func orderChecklistVerification(_ orderId: Order.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let verifiedItemIds = verifiedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { verifiedItemIds.contains($0.id) }
    }
    
    
    func orderChecklistPacked(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    func orderChecklistShipped(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    func orderChecklistTrackingNo(_ orderId: Order.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return !(order.trackingNo ?? "").isEmpty
    }
    
    
    func orderChecklistDriveThru(_ orderId: Order.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return order.driveThruSent
    }
    
    
    func orderChecklistStamping(_ orderId: Order.ID) -> Bool {
        
        if orderIsValidatedWithoutStamping(orderId: orderId) {
            return true
        }
        
        let order = orderDetails(forOrderWithId: orderId)!
        if order.shippingMethodId == shippingMethodId_France_MondialRelay {
            return true
        }
        
        let stamping = stamping(forOrderWithId: orderId)
        
        return !(stamping ?? "").isEmpty
    }
    
    
    func orderChecklistReceived(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    func orderChecklistCompleted(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status == .completed
    }
    
    
    func orderChecklistBuyerFeedback(_ orderId: Order.ID) -> Bool {
        
        return orderFeedbacks(forOrderWithId: orderId).buyerFeedback() != nil
    }
    
    
    func orderChecklistSellerFeedback(_ orderId: Order.ID) -> Bool {
        
        if orderIsValidatedWithoutFeedback(orderId: orderId) {
            return true
        }
        
        return orderFeedbacks(forOrderWithId: orderId).sellerFeedback() != nil
    }
    
    
    func orderChecklistUnchangedFor30Days(_ orderId: Order.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.dateStatusChanged.days(to: Date()) > 30
    }
}
