import Foundation



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
    
    
    private func checklistState_payment(_ order: Order) -> ChecklistState {
        
        order.paymentStatus.isOneOf(.completed, .received) ? .validated : .pending
    }
    
    
    private func checklistState_incomeTransaction(_ order: Order) -> ChecklistState {
        
        if orderIsValidatedWithoutIncomeTransaction(order) {
            
            return .notApplicable
        }
        
        return incomeTransactions(for: order).isEmpty ? .pending : .validated
    }
    
    
    private func checklistState_shippingTransaction(_ order: Order) -> ChecklistState {
        
        if !shippingTransactions(for: order).isEmpty {
            
            return .validated
        }
        
        if orderIsValidatedWithoutShippingTransaction(order) {
            
            return .notApplicable
        }
        
        if let orderDetails = details(for: order), orderDetails.shipsWithLaPoste {
                
            let stamping = stamping(for: order)
            if !(stamping ?? "").isEmpty, stamping != "Bureau de poste" {
                
                return .notApplicable
            }
        }
        
        return .pending
    }
    
    
    private func checklistState_picking(_ order: Order) -> ChecklistState {
        
        pickingProgressController.pickingProgress(for: order) == 100% ? .validated : .pending
    }
    
    
    private func checklistState_verification(_ order: Order) -> ChecklistState {
        
        pickingProgressController.pickingVerificationProgress(for: order) == 100% ? .validated : .pending
    }
    
    
    private func checklistState_packed(_ order: Order) -> ChecklistState {
        
        order.status.isOneOf(.packed, .shipped, .received, .completed) ? .validated : .pending
    }
    
    
    private func checklistState_shipped(_ order: Order) -> ChecklistState {
        
        order.status.isOneOf(.shipped, .received, .completed) ? .validated : .pending
    }
    
    
    private func checklistState_trackingNo(_ order: Order) -> ChecklistState {
            
        (details(for: order)?.trackingNo ?? "").isEmpty ? .pending : .validated
    }
    
    
    private func checklistState_driveThru(_ order: Order) -> ChecklistState {
        
        details(for: order)?.driveThruSent ?? false ? .validated : .pending
    }
    
    
    private func checklistState_stamping(_ order: Order) -> ChecklistState {
        
        if let orderDetails = details(for: order), orderDetails.shipsWithMondialRelay {
            
            return .notApplicable
        }
        
        if orderIsValidatedWithoutStamping(order) {
            
            return .notApplicable
        }
        
        return (stamping(for: order) ?? "").isEmpty ? .pending : .validated
    }
    
    
    private func checklistState_received(_ order: Order) -> ChecklistState {
        
        order.status.isOneOf(.received, .completed) ? .validated : .pending
    }
    
    
    private func checklistState_completed(_ order: Order) -> ChecklistState {
        
        order.status == .completed ? .validated : .pending
    }
    
    
    private func checklistState_buyerFeedback(_ order: Order) -> ChecklistState {
        
        feedbacks(for: order).buyerFeedback() != nil ? .validated : .pending
    }
    
    
    private func checklistState_sellerFeedback(_ order: Order) -> ChecklistState {
        
        if orderIsValidatedWithoutFeedback(order) {
            
            return .validated
        }
        
        return feedbacks(for: order).sellerFeedback() != nil ? .validated : .pending
    }
    
    
    private func checklistState_unchangedFor30Days(_ order: Order) -> ChecklistState {
        
        order.unchangedFor30Days ? .validated : .pending
    }
    
    
    func state(of item: ChecklistItem, for order: Order) -> ChecklistState {
        
        switch item {
            
        case .payment:
            return checklistState_payment(order)
            
        case .incomeTransaction:
            return checklistState_incomeTransaction(order)
            
        case .shippingTransaction:
            return checklistState_shippingTransaction(order)
            
        case .picking:
            return checklistState_picking(order)
            
        case .verification:
            return checklistState_verification(order)
            
        case .packed:
            return checklistState_packed(order)
            
        case .shipped:
            return checklistState_shipped(order)
            
        case .trackingNo:
            return checklistState_trackingNo(order)
            
        case .driveThru:
            return checklistState_driveThru(order)
            
        case .stamping:
            return checklistState_stamping(order)
            
        case .received:
            return checklistState_received(order)
            
        case .completed:
            return checklistState_completed(order)
            
        case .buyerFeedback:
            return checklistState_buyerFeedback(order)
            
        case .sellerFeedback:
            return checklistState_sellerFeedback(order)
            
        case .unchangedFor30Days:
            return checklistState_unchangedFor30Days(order)
        }
    }
    
    
    func order(_ order: Order, validates item: ChecklistItem) -> Bool {
        
        state(of: item, for: order).isOneOf(.validated, .notApplicable)
    }
}


enum ChecklistItem {
    
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


enum ChecklistState: IsOneOfAble {
    
    case validated
    case pending
    case notApplicable
}
