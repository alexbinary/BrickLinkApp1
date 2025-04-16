import Foundation



@MainActor
class MacroStatusController {
    
    
    private let orderController: OrderController
    private let checklistController: ChecklistController
    
    
    init(
        _ orderController: OrderController,
        _ checklistController: ChecklistController
    ) {
        self.orderController = orderController
        self.checklistController = checklistController
    }
    
    
    // MARK: - Order macro status
    
    
    func order(_ order: Order, validates item: ChecklistItem) -> Bool {
        
        checklistController.order(order, validates: item)
    }
    
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        if order.status.isOneOf(.cancelled, .purged) {
            return order.unchangedFor30Days ? .closed : .recentlyClosed
        }
        
        let initialStatus: OrderMacroStatus = .validatePayment
        
        let conditionsStatus: [
            (condition: () -> Bool, status: OrderMacroStatus)
        ] = [
            (condition: {
                self.order(order, validates: .incomeTransaction)
                
            }, status: .pickAndPack
            ),
            (condition: {
                self.order(order, validates: .picking)
                && self.order(order, validates: .verification)
                && self.order(order, validates: .packed)
                
            }, status: .ship
            ),
            (condition: {
                self.order(order, validates: .stamping)
                && self.order(order, validates: .shippingTransaction)
                && self.order(order, validates: .trackingNo)
                && self.order(order, validates: .shipped)
                && self.order(order, validates: .driveThru)
                
            }, status: .inTransit
            ),
            (condition: {
                self.order(order, validates: .received)
                
            }, status: .received
            ),
            (condition: {
                self.order(order, validates: .completed)
                || self.order(order, validates: .buyerFeedback)
                || self.order(order, validates: .unchangedFor30Days)
                
            }, status: .giveFeedback
            ),
            (condition: {
                self.order(order, validates: .sellerFeedback)
                
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
        
        if status == .inTransit, order.unchangedFor30Days {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !order.unchangedFor30Days {
            status = .recentlyClosed
        }
        
        return status
    }
}
