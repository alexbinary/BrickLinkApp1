
import Foundation



@Observable
class FeedbackStore {
    
    
    private let dataStore: DataStore
    private let blCredentials: BrickLinkAPICredentials
    
    
    init(dataStore: DataStore, blCredentials: BrickLinkAPICredentials) {
        self.dataStore = dataStore
        self.blCredentials = blCredentials
    }
    
    
    public func orderFeedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        dataStore.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        orderFeedbacks(forOrderWithId: orderId).buyerFeedback()
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        orderFeedbacks(forOrderWithId: orderId).sellerFeedback()
    }
    
    
    public func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        let blFeedbacks = await BrickLinkAPIClient.fetchFeedbacks(forOrderWithId: orderId, using: blCredentials)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        if !dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        if dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func postOrderFeedback(orderId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await BrickLinkAPIClient.postFeedback(forOrderWithId: orderId, rating: rating, comment: comment, using: blCredentials)
        
        await reloadOrderFeedbacks(forOrderWithId: orderId)
    }
    
    
    public var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date] {
        
        dataStore.dateValidatedWithoutFeedbackByOrderId
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        try! dataStore.setDateValidatedWithoutFeedback(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    public func dateOrderValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Date? {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId]
    }
    
    
    public func orderIsValidatedWithoutFeedback(orderId: OrderDetails.ID) -> Bool {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId] != nil
    }
}
