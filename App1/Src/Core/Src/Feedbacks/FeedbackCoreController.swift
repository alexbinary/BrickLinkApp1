
import Foundation



@MainActor
class FeedbackCoreController {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    
    
    init(_ dataStore: DataStore, _ updateController: UpdateController) {
        
        self.dataStore = dataStore
        self.updateController = updateController
    }
    
    
    // MARK: - Read feedbacks
    
    
    func feedbacks(for order: Order) -> [Feedback] {
        
        dataStore.orderFeedbacksByOrderId[order.id] ?? []
    }
    
    
    func buyerFeedback(for order: Order) -> Feedback? {
        
        feedbacks(for: order).buyerFeedback()
    }
    
    
    func sellerFeedback(for order: Order) -> Feedback? {
        
        feedbacks(for: order).sellerFeedback()
    }
    
    
    func loadFeedbacks(for order: Order) async {
        
        await updateController.loadFeedbacks(for: order, .evenIfNotInvalidated)
    }
    
    
    func loadFeedbacksIfMissing(for order: Order) async {
        
        if !dataStore.orderFeedbacksByOrderId.keys.contains(order.id) {
            
            await loadFeedbacks(for: order)
        }
    }
    
    
    func reloadFeedbacks(for order: Order) async {
        
        if dataStore.orderFeedbacksByOrderId.keys.contains(order.id) {
            
            await loadFeedbacks(for: order)
        }
    }
    
    
    var isLoadingOrderFeedbacks: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadOrderFeedbacks
    }
    
    
    func isLoadingFeedbacks(for order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadFeedbacks(for: order)
    }
    
    
    // MARK: - Post feedback
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await updateController.postFeedback(for: order, rating: rating, comment: comment)
    }
    
    
    var isPostingFeedback: Bool {
        
        updateController.isRunningOrIsScheduledToRun_postOrderFeedback
    }
    
    
    func isPostingFeedback(for order: Order) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_postFeedback(for: order)
    }
    
    
    // MARK: - Validation without feedback
    
    
    var dateValidatedWithoutFeedbackByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutFeedbackByOrderId
    }
    
    
    func validateOrderWithoutFeedback(_ order: Order) {
        
        try! dataStore.setDateValidatedWithoutFeedback(Date(), forOrderId: order.id)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date? {
        
        return dateValidatedWithoutFeedbackByOrderId[order.id]
    }
    
    
    func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        return dateValidatedWithoutFeedbackByOrderId[order.id] != nil
    }
}
