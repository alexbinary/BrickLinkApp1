
import Foundation



@Observable
class OrderController {
    
    
    private let orderStore: OrderStore
    private let orderChecklistController: OrderChecklistController
    
    
    init(_ orderStore: OrderStore, _ orderChecklistController: OrderChecklistController) {
        self.orderStore = orderStore
        self.orderChecklistController = orderChecklistController
    }
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderStore.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderStore.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistIncomeTransaction(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistPicking(orderId)
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistVerification(orderId)
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistPacked(orderId)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistShipped(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistTrackingNo(orderId)
    }
    
    
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistDriveThru(orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistReceived(orderId)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistCompleted(orderId)
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistBuyerFeedback(orderId)
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistSellerFeedback(orderId)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistController.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    // MARK: - Order macro status
    
    
    public func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
        let order = orderSummary(forOrderWithId: orderId)!
        
        if order.status.isOneOf(.cancelled, .purged) {
            return orderChecklistUnchangedFor30Days(orderId) ? .closed : .recentlyClosed
        }
        
        let initialStatus: OrderMacroStatus = .validatePayment
        
        let conditionsStatus: [
            (condition: () -> Bool, status: OrderMacroStatus)
        ] = [
            (condition: {
                self.orderChecklistIncomeTransaction(orderId)
                
            }, status: .pickAndPack
            ),
            (condition: {
                self.orderChecklistPicking(orderId)
                && self.orderChecklistVerification(orderId)
                && self.orderChecklistPacked(orderId)
                
            }, status: .ship
            ),
            (condition: {
                self.orderChecklistStamping(orderId)
                && self.orderChecklistShippingTransaction(orderId)
                && self.orderChecklistTrackingNo(orderId)
                && self.orderChecklistShipped(orderId)
                && self.orderChecklistDriveThru(orderId)
                
            }, status: .inTransit
            ),
            (condition: {
                self.orderChecklistReceived(orderId)
                
            }, status: .received
            ),
            (condition: {
                self.orderChecklistCompleted(orderId)
                || self.orderChecklistBuyerFeedback(orderId)
                || self.orderChecklistUnchangedFor30Days(orderId)
                
            }, status: .giveFeedback
            ),
            (condition: {
                self.orderChecklistSellerFeedback(orderId)
                
            }, status: .closed
            )
        ]
        
        var status = {
            
            var validatedStatus = initialStatus
            for c in conditionsStatus {
                if c.condition() {
                    validatedStatus = c.status
                    continue
                } else {
                    return validatedStatus
                }
            }
            return validatedStatus
        }()
        
        if status == .inTransit, orderChecklistUnchangedFor30Days(orderId) {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !orderChecklistUnchangedFor30Days(orderId) {
            status = .recentlyClosed
        }
        
        return status
    }
    
    
    public func ordersMainListSections(restrictingToOrdersMatching searchText: String) -> [OrdersMainListSection] {
        
        let orders = orderSummaries.filter { $0.matches(searchText) }
        
        var sections: [OrdersMainListSection] = [
            
            .init(
                header: OrderMacroStatus.inTransitFor30PlusDays.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransitFor30PlusDays }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.giveFeedback.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .giveFeedback }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.validatePayment.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .validatePayment }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.pickAndPack.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .pickAndPack }
                    .sorted {
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && orderChecklistVerification($0.id)
                        ||
                        orderChecklistVerification($0.id) != orderChecklistVerification($1.id)
                        && $0.lots < $1.lots
                    }
            ),
            .init(
                header: OrderMacroStatus.ship.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .ship }
                    .sorted { $0.date > $1.date }
            ),
            .init(
                header: OrderMacroStatus.received.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .received }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.inTransit.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .inTransit }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
            .init(
                header: OrderMacroStatus.recentlyClosed.descriptionWithPicto,
                orders: orders
                    .filter { macroStatus(forOrderWithId: $0.id) == .recentlyClosed }
                    .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            ),
        ]
        
        let closedOrders = orders
            .filter { macroStatus(forOrderWithId: $0.id) == .closed }
            .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
        
        sections.append(contentsOf: closedOrders.grouppedByMonth.map { item in
            .init(
                header: "􀤟 \(item.month)",
                orders: item.elements
            )
        })
        
        return sections
    }
    
    
    public var ordersThatNeedAction: [OrderSummary] {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }
    }
}
