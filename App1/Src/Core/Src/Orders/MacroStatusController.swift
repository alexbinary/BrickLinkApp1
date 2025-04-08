import Foundation



@Observable
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
    
    
    func checklist_incomeTransaction(_ order: Order) -> Bool {
        
        checklistController.checklist_incomeTransaction(order)
    }
    
    
    func checklist_shippingTransaction(_ order: Order) -> Bool {
        
        checklistController.checklist_shippingTransaction(order)
    }
    
    
    func checklist_picking(_ order: Order) -> Bool {
        
        checklistController.checklist_picking(order)
    }
    
    
    func checklist_verification(_ order: Order) -> Bool {
        
        checklistController.checklist_verification(order)
    }
    
    
    func checklist_packed(_ order: Order) -> Bool {
        
        checklistController.checklist_packed(order)
    }
    
    
    func checklist_shipped(_ order: Order) -> Bool {
        
        checklistController.checklist_shipped(order)
    }
    
    
    func checklist_trackingNo(_ order: Order) -> Bool {
        
        checklistController.checklist_trackingNo(order)
    }
    
    
    func checklist_driveThru(_ order: Order) -> Bool {
        
        checklistController.checklist_driveThru(order)
    }
    
    
    func checklist_stamping(_ order: Order) -> Bool {
        
        checklistController.checklist_stamping(order)
    }
    
    
    func checklist_received(_ order: Order) -> Bool {
        
        checklistController.checklist_received(order)
    }
    
    
    func checklist_completed(_ order: Order) -> Bool {
        
        checklistController.checklist_completed(order)
    }
    
    
    func checklist_buyerFeedback(_ order: Order) -> Bool {
        
        checklistController.checklist_buyerFeedback(order)
    }
    
    
    func checklist_sellerFeedback(_ order: Order) -> Bool {
        
        checklistController.checklist_sellerFeedback(order)
    }
    
    
    func checklist_unchangedFor30Days(_ order: Order) -> Bool {
        
        checklistController.checklist_unchangedFor30Days(order)
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
        
        if status == .inTransit, order.unchangedFor30Days {
            status = .inTransitFor30PlusDays
        }
        
        if status == .closed, !order.unchangedFor30Days {
            status = .recentlyClosed
        }
        
        return status
    }
}
