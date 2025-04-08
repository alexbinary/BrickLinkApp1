
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
    
    
    private func orderIsValidatedWithoutIncomeTransaction(_ order: Order) -> Bool {
        
        transactionCoreController.orderIsValidatedWithoutIncomeTransaction(order)
    }
    
    
    private func incomeTransactions(for order: Order) -> [Transaction] {
        
        transactionCoreController.incomeTransactions(for: order)
    }
    
    
    private func shippingTransactions(for order: Order) -> [Transaction] {
        
        transactionCoreController.shippingTransactions(for: order)
    }
    
    
    private func orderIsValidatedWithoutShippingTransaction(_ order: Order) -> Bool {
        
        transactionCoreController.orderIsValidatedWithoutShippingTransaction(order)
    }
    
    
    private func details(for order: Order) -> OrderDetails? {
        
        orderCoreController.details(for: order)
    }
    
    
    private func stamping(for order: Order) -> String? {
        
        shippingCoreController.confirmedStamping(for: order)
    }
    
    
    private func orderIsValidatedWithoutStamping(_ order: Order) -> Bool {
        
        shippingCoreController.orderIsValidatedWithoutStamping(order)
    }
    
    
    private func items(for order: Order) -> [OrderItem] {
        
        orderCoreController.items(for: order)
    }
    
    
    private func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.pickedItemIds(for: order)
    }
    
    
    private func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingCoreController.verifiedItemIds(for: order)
    }
    
    
    private func feedbacks(for order: Order) -> [Feedback] {
        
        feedbackCoreController.feedbacks(for: order)
    }
    
    
    private func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        feedbackCoreController.orderIsValidatedWithoutFeedback(order)
    }
    
    
    // -
    
    
    func orderChecklistPayment(_ order: Order) -> Bool {
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    func orderChecklistIncomeTransaction(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(order) {
            
            return true
        }
        
        return !incomeTransactions(for: order).isEmpty
    }
    
    
    func orderChecklistShippingTransaction(_ order: Order) -> Bool {
        
        if !shippingTransactions(for: order).isEmpty {
            
            return true
        }
        
        if orderIsValidatedWithoutShippingTransaction(order) {
            
            return true
        }
        
        if let orderDetails = details(for: order), orderDetails.shipsWithLaPoste {
                
            let stamping = stamping(for: order)
            if !(stamping ?? "").isEmpty, stamping != "Bureau de poste" {
                
                return true
            }
        }
        
        return false
    }
    
    
    func orderChecklistPicking(_ order: Order) -> Bool {
        
        pickingProgressCoreController.pickingProgress(for: order) == 100%
    }
    
    
    func orderChecklistVerification(_ order: Order) -> Bool {
        
        pickingProgressCoreController.pickingVerificationProgress(for: order) == 100%
    }
    
    
    func orderChecklistPacked(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    func orderChecklistShipped(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    func orderChecklistTrackingNo(_ order: Order) -> Bool {
            
        return (details(for: order)?.trackingNo ?? "").isEmpty ? false : true
    }
    
    
    func orderChecklistDriveThru(_ order: Order) -> Bool {
        
        details(for: order)?.driveThruSent ?? false
    }
    
    
    func orderChecklistStamping(_ order: Order) -> Bool {
        
        if let orderDetails = details(for: order), orderDetails.shipsWithMondialRelay {
            
            return true
        }
        
        if orderIsValidatedWithoutStamping(order) {
            
            return true
        }
        
        return (stamping(for: order) ?? "").isEmpty ? false : true
    }
    
    
    func orderChecklistReceived(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    func orderChecklistCompleted(_ order: Order) -> Bool {
        
        return order.status == .completed
    }
    
    
    func orderChecklistBuyerFeedback(_ order: Order) -> Bool {
        
        return feedbacks(for: order).buyerFeedback() != nil
    }
    
    
    func orderChecklistSellerFeedback(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutFeedback(order) {
            
            return true
        }
        
        return feedbacks(for: order).sellerFeedback() != nil
    }
    
    
    func orderChecklistUnchangedFor30Days(_ order: Order) -> Bool {
        
        return order.dateStatusChanged.days(to: Date()) > 30
    }
}
