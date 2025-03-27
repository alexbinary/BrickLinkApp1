
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
    
    
    func orderChecklistIncomeTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistIncomeTransaction(orderId)
    }
    
    
    func orderChecklistShippingTransaction(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistShippingTransaction(orderId)
    }
    
    
    func orderChecklistPicking(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistPicking(orderId)
    }
    
    
    func orderChecklistVerification(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistVerification(orderId)
    }
    
    
    func orderChecklistPacked(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistPacked(orderId)
    }
    
    
    func orderChecklistShipped(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistShipped(orderId)
    }
    
    
    func orderChecklistTrackingNo(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistTrackingNo(orderId)
    }
    
    
    func orderChecklistDriveThru(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistDriveThru(orderId)
    }
    
    
    func orderChecklistStamping(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistStamping(orderId)
    }
    
    
    func orderChecklistReceived(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistReceived(orderId)
    }
    
    
    func orderChecklistCompleted(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistCompleted(orderId)
    }
    
    
    func orderChecklistBuyerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistBuyerFeedback(orderId)
    }
    
    
    func orderChecklistSellerFeedback(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistSellerFeedback(orderId)
    }
    
    
    func orderChecklistUnchangedFor30Days(_ orderId: OrderSummary.ID) -> Bool {
        
        orderChecklistCoreController.orderChecklistUnchangedFor30Days(orderId)
    }
    
    
    // MARK: - Order summaries
    
    
    func orderSummary(forOrderWithId orderId: OrderDetails.ID) -> OrderSummary? {
        
        orderCoreController.orderSummary(forOrderWithId: orderId)
    }
    
    
    // MARK: - Order macro status
    
    
    func macroStatus(forOrderWithId orderId: OrderSummary.ID) -> OrderMacroStatus {
        
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
}
