
import Foundation



class FeedbackCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Read feedbacks
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        dataStore.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).buyerFeedback()
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).sellerFeedback()
    }
    
    
    public func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(forOrderWithId: orderId)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
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
    
    
    // MARK: - Post feedback
    
    
    public func postFeedback(forOrderWithId: OrderSummary.ID, rating: BrickLinkFeedbackRating, comment: String) async {
        
        await brickLinkAPIClient.postFeedback(forOrderWithId: forOrderWithId, rating: rating.rawValue, comment: comment)
        
        await reloadOrderFeedbacks(forOrderWithId: forOrderWithId)
    }
    
    
    // MARK: - Validation without feedback
    
    
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



extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        
        self.id = bl.feedbackId
        self.orderId = "\(bl.orderId)"
        self.from = bl.from
        self.to = bl.to
        self.dateRated = bl.dateRated
        self.rating = bl.rating
        self.author = FeedbackAuthor(fromBl: bl.ratingOfBs)!
        self.comment = bl.comment
    }
}



extension FeedbackAuthor {
    
    
    init?(fromBl bl: BrickLinkFeedbackRatingOfBS) {
        
        switch bl {
        case .forBuyer: self = .seller
        case .forSeller: self = .buyer
        }
    }
}
