
import Foundation



@Observable
@MainActor
class ChecklistController {
    
    
    private let orderController: OrderController
    private let pickingController: PickingController
    private let shippingController: ShippingController
    private let feedbackController: FeedbackController
    private let transactionController: TransactionController
    private let trackingMiddleController: TrackingMiddleController
    private let pickingProgressController: PickingProgressController
    
    
    init(
        _ orderController: OrderController,
        _ pickingController: PickingController,
        _ shippingController: ShippingController,
        _ feedbackController: FeedbackController,
        _ transactionController: TransactionController,
        _ trackingMiddleController: TrackingMiddleController,
        _ pickingProgressController: PickingProgressController
    ) {
        self.orderController = orderController
        self.pickingController = pickingController
        self.shippingController = shippingController
        self.feedbackController = feedbackController
        self.transactionController = transactionController
        self.trackingMiddleController = trackingMiddleController
        self.pickingProgressController = pickingProgressController
    }
    
    
    private func orderIsValidatedWithoutIncomeTransaction(_ order: Order) -> Bool {
        
        transactionController.orderIsValidatedWithoutIncomeTransaction(order)
    }
    
    
    private func incomeTransactions(for order: Order) -> [Transaction] {
        
        transactionController.incomeTransactions(for: order)
    }
    
    
    private func shippingTransactions(for order: Order) -> [Transaction] {
        
        transactionController.shippingTransactions(for: order)
    }
    
    
    private func orderIsValidatedWithoutShippingTransaction(_ order: Order) -> Bool {
        
        transactionController.orderIsValidatedWithoutShippingTransaction(order)
    }
    
    
    private func details(for order: Order) -> OrderDetails? {
        
        orderController.details(for: order)
    }
    
    
    private func stamping(for order: Order) -> String? {
        
        shippingController.confirmedStamping(for: order)
    }
    
    
    private func orderIsValidatedWithoutStamping(_ order: Order) -> Bool {
        
        shippingController.orderIsValidatedWithoutStamping(order)
    }
    
    
    private func items(for order: Order) -> [OrderItem] {
        
        orderController.items(for: order)
    }
    
    
    private func pickedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.pickedItemIds(for: order)
    }
    
    
    private func verifiedItemIds(for order: Order) -> [OrderItem.ID] {
        
        pickingController.verifiedItemIds(for: order)
    }
    
    
    private func feedbacks(for order: Order) -> [Feedback] {
        
        feedbackController.feedbacks(for: order)
    }
    
    
    private func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        feedbackController.orderIsValidatedWithoutFeedback(order)
    }
    
    
    func checklist_payment(_ order: Order) -> Bool {
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    func checklist_incomeTransaction(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(order) {
            
            return true
        }
        
        return !incomeTransactions(for: order).isEmpty
    }
    
    
    func checklist_shippingTransaction(_ order: Order) -> Bool {
        
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
    
    
    func checklist_picking(_ order: Order) -> Bool {
        
        pickingProgressController.pickingProgress(for: order) == 100%
    }
    
    
    func checklist_verification(_ order: Order) -> Bool {
        
        pickingProgressController.pickingVerificationProgress(for: order) == 100%
    }
    
    
    func checklist_packed(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    func checklist_shipped(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    func checklist_trackingNo(_ order: Order) -> Bool {
            
        return (details(for: order)?.trackingNo ?? "").isEmpty ? false : true
    }
    
    
    func checklist_driveThru(_ order: Order) -> Bool {
        
        details(for: order)?.driveThruSent ?? false
    }
    
    
    func checklist_stamping(_ order: Order) -> Bool {
        
        if let orderDetails = details(for: order), orderDetails.shipsWithMondialRelay {
            
            return true
        }
        
        if orderIsValidatedWithoutStamping(order) {
            
            return true
        }
        
        return (stamping(for: order) ?? "").isEmpty ? false : true
    }
    
    
    func checklist_received(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    func checklist_completed(_ order: Order) -> Bool {
        
        return order.status == .completed
    }
    
    
    func checklist_buyerFeedback(_ order: Order) -> Bool {
        
        return feedbacks(for: order).buyerFeedback() != nil
    }
    
    
    func checklist_sellerFeedback(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutFeedback(order) {
            
            return true
        }
        
        return feedbacks(for: order).sellerFeedback() != nil
    }
    
    
    func checklist_unchangedFor30Days(_ order: Order) -> Bool {
        
        order.unchangedFor30Days
    }
}
