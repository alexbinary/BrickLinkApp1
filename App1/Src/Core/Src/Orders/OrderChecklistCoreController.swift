
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
        
        pickingProgressCoreController.pickingProgress(for: order) == 100%
    }
    
    
    func checklist_verification(_ order: Order) -> Bool {
        
        pickingProgressCoreController.pickingVerificationProgress(for: order) == 100%
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
        
        return order.dateStatusChanged.days(to: Date()) > 30
    }


    func checklist(for order: Order) -> Checklist {
        
        Checklist(
            payment: checklist_payment(order),
            incomeTransaction: checklist_incomeTransaction(order),
            shippingTransaction: checklist_shippingTransaction(order),
            picking: checklist_picking(order),
            verification: checklist_verification(order),
            packed: checklist_packed(order),
            shipped: checklist_shipped(order),
            trackingNo: checklist_trackingNo(order),
            driveThru: checklist_driveThru(order),
            stamping: checklist_stamping(order),
            received: checklist_received(order),
            completed: checklist_completed(order),
            buyerFeedback: checklist_buyerFeedback(order),
            sellerFeedback: checklist_sellerFeedback(order),
            unchangedFor30Days: checklist_unchangedFor30Days(order)
        )
    }
}



struct Checklist {
    
    let payment: Bool
    let incomeTransaction: Bool
    let shippingTransaction: Bool
    let picking: Bool
    let verification: Bool
    let packed: Bool
    let shipped: Bool
    let trackingNo: Bool
    let driveThru: Bool
    let stamping: Bool
    let received: Bool
    let completed: Bool
    let buyerFeedback: Bool
    let sellerFeedback: Bool
    let unchangedFor30Days: Bool
}
