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
    
    
    // MARK: - Order macro status
    
    
    func checklist_incomeTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_incomeTransaction(order)
    }
    
    
    func checklist_shippingTransaction(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_shippingTransaction(order)
    }
    
    
    func checklist_picking(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_picking(order)
    }
    
    
    func checklist_verification(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_verification(order)
    }
    
    
    func checklist_packed(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_packed(order)
    }
    
    
    func checklist_shipped(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_shipped(order)
    }
    
    
    func checklist_trackingNo(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_trackingNo(order)
    }
    
    
    func checklist_driveThru(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_driveThru(order)
    }
    
    
    func checklist_stamping(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_stamping(order)
    }
    
    
    func checklist_received(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_received(order)
    }
    
    
    func checklist_completed(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_completed(order)
    }
    
    
    func checklist_buyerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_buyerFeedback(order)
    }
    
    
    func checklist_sellerFeedback(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_sellerFeedback(order)
    }
    
    
    func checklist_unchangedFor30Days(_ order: Order) -> Bool {
        
        orderChecklistCoreController.checklist_unchangedFor30Days(order)
    }
    
    
    func macroStatus(for order: Order) -> OrderMacroStatus {
        
        if order.status.isOneOf(.cancelled, .purged) {
            return checklist_unchangedFor30Days(order) ? .closed : .recentlyClosed
        }
        
        let initialStatus: OrderMacroStatus = .validatePayment
        
        let conditionsStatus: [
            (condition: () -> Bool, status: OrderMacroStatus)
        ] = [
            (condition: {
                self.checklist_incomeTransaction(order)
                
            }, status: .pickAndPack
            ),
            (condition: {
                self.checklist_picking(order)
                && self.checklist_verification(order)
                && self.checklist_packed(order)
                
            }, status: .ship
            ),
            (condition: {
                self.checklist_stamping(order)
                && self.checklist_shippingTransaction(order)
                && self.checklist_trackingNo(order)
                && self.checklist_shipped(order)
                && self.checklist_driveThru(order)
                
            }, status: .inTransit
            ),
            (condition: {
                self.checklist_received(order)
                
            }, status: .received
            ),
            (condition: {
                self.checklist_completed(order)
                || self.checklist_buyerFeedback(order)
                || self.checklist_unchangedFor30Days(order)
                
            }, status: .giveFeedback
            ),
            (condition: {
                self.checklist_sellerFeedback(order)
                
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
        
        if status == .inTransit, checklist_unchangedFor30Days(order) {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !checklist_unchangedFor30Days(order) {
            status = .recentlyClosed
        }
        
        return status
    }
}
