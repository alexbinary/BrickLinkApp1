
import SwiftUI



struct PreviewFeedbackStore: FeedbackStoreProtocol {


    func feedbacks(for order: Order) -> [Feedback] {
        
        return []
    }
    
    func buyerFeedback(for order: Order) -> Feedback? {
        
        return nil
    }
    
    func sellerFeedback(for order: Order) -> Feedback? {
        
        return nil
    }
    
    func isLoadingFeedbacks(for order: Order) -> Bool {
        
        return false
    }
    
    func softRefreshFeedbacks(for order: Order) async {
        
    }
    
    func hardRefreshFeedbacks(forOrderWithId orderId: Order.ID, _ operationTag: OperationTag?) async {
        
    }

    func postPraiseFeedback(for order: Order) async {
        
    }
    
    func dateOrderValidatedWithoutFeedback(_ order: Order) -> Date? {
        
        return nil
    }
    
    func orderIsValidatedWithoutFeedback(_ order: Order) -> Bool {
        
        return false
    }
    
    func validateOrderWithoutFeedback(_ order: Order) {
        
    }
}
