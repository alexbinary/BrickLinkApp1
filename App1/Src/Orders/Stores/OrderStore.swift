
import Foundation



@Observable
class OrderStore {
    
    
    private let orderDataAccess: OrderDataAccess
    private let orderChecklistStore: OrderChecklistStore
    
    
    init(_ orderDataAccess: OrderDataAccess, _ orderChecklistStore: OrderChecklistStore) {
        self.orderDataAccess = orderDataAccess
        self.orderChecklistStore = orderChecklistStore
    }
    
    
    public func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistIncomeTransaction(orderId)
    }
    
    
    public func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistShippingTransaction(orderId)
    }
    
    
    public func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistPicking(orderId)
    }
    
    
    public func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistVerification(orderId)
    }
    
    
    public func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistPacked(orderId)
    }
    
    
    public func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistShipped(orderId)
    }
    
    
    public func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistTrackingNo(orderId)
    }
    
    
    public func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistDriveThru(orderId)
    }
    
    
    public func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistStamping(orderId)
    }
    
    
    public func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistReceived(orderId)
    }
    
    
    public func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistCompleted(orderId)
    }
    
    
    public func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistBuyerFeedback(orderId)
    }
    
    
    public func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistSellerFeedback(orderId)
    }
    
    
    public func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistStore.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    // MARK: - Order summaries
    
    
    public var orderSummaries: [OrderSummary] {
        
        orderDataAccess.orderSummaries
    }
    
    
    public func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderDataAccess.orderSummary(forOrderWithId: orderId)
    }
    
    
    public func loadOrderSummaries() async {
        
        await orderDataAccess.loadOrderSummaries()
    }
    
    
    // MARK: - Orders details
    
    
    public var orderDetails: [OrderDetails] {
        
        orderDataAccess.orderDetails
    }
    
    
    public func orderDetails(forOrderWithId orderId: OrderSummary.ID) -> OrderDetails? {
        
        orderDataAccess.orderDetails(forOrderWithId: orderId)
    }
    
    
    // MARK: - Order status, Tracking no, Drive thru
    
    
    public func updateOrderStatus(orderId: OrderSummary.ID, status: OrderStatus) async {
        
        await orderDataAccess.updateOrderStatus(orderId: orderId, status: status)
    }
    
    
    public func updateTrackingNo(forOrderWithId orderId: OrderSummary.ID, trackingNo: String) async {
        
        await orderDataAccess.updateTrackingNo(forOrderWithId: orderId, trackingNo: trackingNo)
    }
    
    
    public func sendDriveThru(orderId: OrderSummary.ID) async {
        
        await orderDataAccess.sendDriveThru(orderId: orderId)
    }
    
    
    // MARK: - Order items
    
    
    public func orderItems(forOrderWithId orderId: OrderSummary.ID) -> [OrderItem] {
        
        orderDataAccess.orderItems(forOrderWithId: orderId)
    }
    
    
    public func loadOrderItemsIfMissing(forOrderWithId orderId: String) async {
        
        await orderDataAccess.loadOrderItemsIfMissing(forOrderWithId: orderId)
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
    
    
    public var numberForSidebarBadge: Int {
        
        orderSummaries.filter {
            macroStatus(forOrderWithId: $0.id).isOneOf(
                .ship, .pickAndPack, .validatePayment, .giveFeedback, .inTransitFor30PlusDays
            )
        }.count
    }
}
