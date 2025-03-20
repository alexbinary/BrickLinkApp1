
import Foundation



@Observable
class OrderChecklistController {
    
    
    private let orderDataAccess: OrderDataAccess
    private let pickingDataAccess: PickingDataAccess
    private let shippingDataAccess: ShippingDataAccess
    private let feedbackDataAccess: FeedbackDataAccess
    private let transactionDataAccess: TransactionDataAccess
    private let trackingController: TrackingController
    private let pickingController: PickingController
    
    
    init(_ orderDataAccess: OrderDataAccess, _ pickingDataAccess: PickingDataAccess, _ shippingDataAccess: ShippingDataAccess, _ feedbackDataAccess: FeedbackDataAccess, _ transactionDataAccess: TransactionDataAccess, _ trackingController: TrackingController, _ pickingController: PickingController) {
        self.orderDataAccess = orderDataAccess
        self.pickingDataAccess = pickingDataAccess
        self.shippingDataAccess = shippingDataAccess
        self.feedbackDataAccess = feedbackDataAccess
        self.transactionDataAccess = transactionDataAccess
        self.trackingController = trackingController
        self.pickingController = pickingController
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderDataAccess.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutIncomeTransaction(orderId: OrderDetails.ID) -> Bool {
        
        transactionDataAccess.orderIsValidatedWithoutIncomeTransaction(orderId: orderId)
    }
    
    
    public func incomeTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.incomeTransactions(forOrderWithId: orderId)
    }
    
    
    public func shippingTransactions(forOrderWithId orderId: OrderDetails.ID) -> [Transaction] {
        
        transactionDataAccess.shippingTransactions(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutShippingTransaction(orderId: OrderDetails.ID) -> Bool {
        
        transactionDataAccess.orderIsValidatedWithoutShippingTransaction(orderId: orderId)
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDataAccess.orderDetails(forOrderWithId: orderId)
    }
    
    
    public func stamping(forOrderWithId orderId: OrderSummary.ID) -> String? {
        
        shippingDataAccess.confirmedStamping(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutStamping(orderId: OrderDetails.ID) -> Bool {
        
        shippingDataAccess.orderIsValidatedWithoutStamping(orderId: orderId)
    }
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderDataAccess.orderItems(forOrderWithId: orderId)
    }
    
    
    public func pickedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingDataAccess.pickedItemIds(forOrderWithId: orderId)
    }
    
    
    public func verifiedItemIds(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem.ID] {
        
        pickingDataAccess.verifiedItemIds(forOrderWithId: orderId)
    }
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        feedbackDataAccess.feedbacks(forOrderWithId: orderId)
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        feedbackDataAccess.orderIsValidatedWithoutFeedback(orderId: orderId)
    }
    
    
    // -
    
    
    public func orderChecklistPayment(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.paymentStatus.isOneOf(.completed, .received)
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        if orderIsValidatedWithoutIncomeTransaction(orderId: orderId) {
            return true
        }
        return !incomeTransactions(forOrderWithId: orderId).isEmpty
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
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
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let pickedItemIds = pickedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { pickedItemIds.contains($0.id) }
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        let items = orderItems(forOrderWithId: orderId)
        
        let verifiedItemIds = verifiedItemIds(forOrderWithId: orderId)
        
        return items.allSatisfy { verifiedItemIds.contains($0.id) }
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.packed, .shipped, .received, .completed)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.shipped, .received, .completed)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return !(order.trackingNo ?? "").isEmpty
    }
    
    
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderDetails(forOrderWithId: orderId)!
        
        return order.driveThruSent
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
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
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status.isOneOf(.received, .completed)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.status == .completed
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        return orderFeedbacks(forOrderWithId: orderId).buyerFeedback() != nil
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        if orderIsValidatedWithoutFeedback(orderId: orderId) {
            return true
        }
        
        return orderFeedbacks(forOrderWithId: orderId).sellerFeedback() != nil
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        return order.dateStatusChanged.days(to: Date()) > 30
    }
    
    
    // -
    
    
    public func checklist(forOrderWithId orderId: OrderSummary.ID) -> Checklist {
        
        Checklist(sections: [
            .init(
                title: OrderMacroStatus.validatePayment.descriptionWithPicto,
                items: [
                    .init(
                        label: "Payment received",
                        checked: orderChecklistPayment(orderId)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistIncomeTransaction(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                items: [
                    .init(
                        label: {
                            let progress = pickingController.pickingProgress(forOrderWithId: orderId)
                            if progress == 100% {
                                return  "Pick items"
                            } else {
                                return "Pick items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistPicking(orderId)
                    ),
                    .init(
                        label: {
                            let progress = pickingController.pickingVerificationProgress(forOrderWithId: orderId)
                            if progress == 100% {
                                return "Verify items"
                            } else {
                                return "Verify items - \(progress) complete"
                            }
                        }(),
                        checked: orderChecklistVerification(orderId)
                    ),
                    .init(
                        label: "Pack order",
                        checked: orderChecklistPacked(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.ship.descriptionWithPicto,
                items: [
                    .init(
                        label: "Validate stamping",
                        checked: orderChecklistStamping(orderId)
                    ),
                    .init(
                        label: "Register transaction",
                        checked: orderChecklistShippingTransaction(orderId)
                    ),
                    .init(
                        label: "Input tracking no",
                        checked: orderChecklistTrackingNo(orderId)
                    ),
                    .init(
                        label: "Mark Shipped",
                        checked: orderChecklistShipped(orderId)
                    ),
                    .init(
                        label: "Send drive thru",
                        checked: orderChecklistDriveThru(orderId)
                    ),
                ]
            ),
            .init(
                title: "􀐚 Shipped",
                items: [
                    .init(
                        label: "Picked up by transporter",
                        checked: trackingController.laPosteTrackingStatus(forOrderWithId: orderId)?.isOneOf(.inTransit, .delivered) ?? false,
                        mandatory: false
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.inTransit.descriptionWithPicto,
                items: [
                    .init(
                        label: "Received",
                        checked: orderChecklistReceived(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.received.descriptionWithPicto,
                items: [
                    .init(
                        label: "Completed",
                        checked: orderChecklistCompleted(orderId)
                    ),
                    .init(
                        label: "Buyer feedback",
                        checked: orderChecklistBuyerFeedback(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                items: [
                    .init(
                        label: "Give feedback",
                        checked: orderChecklistSellerFeedback(orderId)
                    ),
                ]
            ),
            .init(
                title: OrderMacroStatus.closed.descriptionWithPicto,
                items: []
            ),
        ])
    }
}



struct Checklist {
    
    let sections: [Section]
    
    struct Section: Identifiable {
        
        var id: String { title }
        let title: String
        let items: [Item]
    }
    
    struct Item: Identifiable {
        
        var id: String { label }
        let label: String
        let checked: Bool
        let mandatory: Bool
        
        init(label: String, checked: Bool, mandatory: Bool = true) {
            self.label = label
            self.checked = checked
            self.mandatory = mandatory
        }
    }
}
