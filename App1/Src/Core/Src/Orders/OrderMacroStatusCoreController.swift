
import Foundation



@Observable
@MainActor
class OrderMacroStatusCoreController {
    
    
    private let orderCoreController: OrderCoreController
    private let orderChecklistCoreController: OrderChecklistCoreController
    
    
    init(
        _ orderCoreController: OrderCoreController,
        _ orderChecklistCoreController: OrderChecklistCoreController
    ) {
        self.orderCoreController = orderCoreController
        self.orderChecklistCoreController = orderChecklistCoreController
    }
    
    
    func orderChecklistIncomeTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistIncomeTransaction(order)
    }
    
    
    func orderChecklistShippingTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistShippingTransaction(order)
    }
    
    
    func orderChecklistPicking(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistPicking(order)
    }
    
    
    func orderChecklistVerification(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistVerification(order)
    }
    
    
    func orderChecklistPacked(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistPacked(order)
    }
    
    
    func orderChecklistShipped(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistShipped(order)
    }
    
    
    func orderChecklistTrackingNo(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistTrackingNo(order)
    }
    
    
    func orderChecklistDriveThru(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistDriveThru(order)
    }
    
    
    func orderChecklistStamping(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistStamping(order)
    }
    
    
    func orderChecklistReceived(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistReceived(order)
    }
    
    
    func orderChecklistCompleted(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistCompleted(order)
    }
    
    
    func orderChecklistBuyerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistBuyerFeedback(order)
    }
    
    
    func orderChecklistSellerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistSellerFeedback(order)
    }
    
    
    func orderChecklistUnchangedFor30Days(_ order: Order) -> Bool {
        
        orderChecklistCoreController.orderChecklistUnchangedFor30Days(order)
    }
    
    
    // MARK: - Order summaries
    
    
    //
    func orderSummary(forOrderId orderId: Order.ID) -> Order? {
        
        orderCoreController.orderSummary(forOrderId: orderId)
    }
    
    
    // MARK: - Order macro status
    
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        if order.status.isOneOf(.cancelled, .purged) {
            return orderChecklistUnchangedFor30Days(order) ? .closed : .recentlyClosed
        }
        
        let initialStatus: OrderMacroStatus = .validatePayment
        
        let conditionsStatus: [
            (condition: () -> Bool, status: OrderMacroStatus)
        ] = [
            (condition: {
                self.orderChecklistIncomeTransaction(order)
                
            }, status: .pickAndPack
            ),
            (condition: {
                self.orderChecklistPicking(order)
                && self.orderChecklistVerification(order)
                && self.orderChecklistPacked(order)
                
            }, status: .ship
            ),
            (condition: {
                self.orderChecklistStamping(order)
                && self.orderChecklistShippingTransaction(order)
                && self.orderChecklistTrackingNo(order)
                && self.orderChecklistShipped(order)
                && self.orderChecklistDriveThru(order)
                
            }, status: .inTransit
            ),
            (condition: {
                self.orderChecklistReceived(order)
                
            }, status: .received
            ),
            (condition: {
                self.orderChecklistCompleted(order)
                || self.orderChecklistBuyerFeedback(order)
                || self.orderChecklistUnchangedFor30Days(order)
                
            }, status: .giveFeedback
            ),
            (condition: {
                self.orderChecklistSellerFeedback(order)
                
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
        
        if status == .inTransit, orderChecklistUnchangedFor30Days(order) {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !orderChecklistUnchangedFor30Days(order) {
            status = .recentlyClosed
        }
        
        return status
    }
}
