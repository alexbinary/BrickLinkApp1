import Foundation



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
    
    
    private func checklist_payment(_ order: Order) -> Bool {
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    private func checklist_incomeTransaction(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(order) {
            
            return true
        }
        
        return !incomeTransactions(for: order).isEmpty
    }
    
    
    private func checklist_shippingTransaction(_ order: Order) -> Bool {
        
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
    
    
    private func checklist_picking(_ order: Order) -> Bool {
        
        pickingProgressController.pickingProgress(for: order) == 100%
    }
    
    
    private func checklist_verification(_ order: Order) -> Bool {
        
        pickingProgressController.pickingVerificationProgress(for: order) == 100%
    }
    
    
    private func checklist_packed(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    private func checklist_shipped(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    private func checklist_trackingNo(_ order: Order) -> Bool {
            
        return (details(for: order)?.trackingNo ?? "").isEmpty ? false : true
    }
    
    
    private func checklist_driveThru(_ order: Order) -> Bool {
        
        details(for: order)?.driveThruSent ?? false
    }
    
    
    private func checklist_stamping(_ order: Order) -> Bool {
        
        if let orderDetails = details(for: order), orderDetails.shipsWithMondialRelay {
            
            return true
        }
        
        if orderIsValidatedWithoutStamping(order) {
            
            return true
        }
        
        return (stamping(for: order) ?? "").isEmpty ? false : true
    }
    
    
    private func checklist_received(_ order: Order) -> Bool {
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    private func checklist_completed(_ order: Order) -> Bool {
        
        return order.status == .completed
    }
    
    
    private func checklist_buyerFeedback(_ order: Order) -> Bool {
        
        return feedbacks(for: order).buyerFeedback() != nil
    }
    
    
    private func checklist_sellerFeedback(_ order: Order) -> Bool {
        
        if orderIsValidatedWithoutFeedback(order) {
            
            return true
        }
        
        return feedbacks(for: order).sellerFeedback() != nil
    }
    
    
    private func checklist_unchangedFor30Days(_ order: Order) -> Bool {
        
        order.unchangedFor30Days
    }
    
    
    func order(_ order: Order, validates item: ChecklistItem) -> Bool {
        
        switch item {
            
        case .payment:
            return checklist_payment(order)
            
        case .incomeTransaction:
            return checklist_incomeTransaction(order)
            
        case .shippingTransaction:
            return checklist_shippingTransaction(order)
            
        case .picking:
            return checklist_picking(order)
            
        case .verification:
            return checklist_verification(order)
            
        case .packed:
            return checklist_packed(order)
            
        case .shipped:
            return checklist_shipped(order)
            
        case .trackingNo:
            return checklist_trackingNo(order)
            
        case .driveThru:
            return checklist_driveThru(order)
            
        case .stamping:
            return checklist_stamping(order)
            
        case .received:
            return checklist_received(order)
            
        case .completed:
            return checklist_completed(order)
            
        case .buyerFeedback:
            return checklist_buyerFeedback(order)
            
        case .sellerFeedback:
            return checklist_sellerFeedback(order)
            
        case .unchangedFor30Days:
            return checklist_unchangedFor30Days(order)
        }
    }
}


public enum ChecklistItem {
    
    case payment
    case incomeTransaction
    case shippingTransaction
    case picking
    case verification
    case packed
    case shipped
    case trackingNo
    case driveThru
    case stamping
    case received
    case completed
    case buyerFeedback
    case sellerFeedback
    case unchangedFor30Days
}
