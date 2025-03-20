
import Foundation



class FeedbackDataAccess {
    
    
    private let fileDataAccess: FileDataAccess
    
    
    init(_ fileDataAccess: FileDataAccess) {
        self.fileDataAccess = fileDataAccess
    }
    
    
    public func feedbacks(forOrderWithId orderId: OrderSummary.ID) -> [Feedback] {
        
        fileDataAccess.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    public func buyerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).buyerFeedback()
    }
    
    
    public func sellerFeedback(forOrderWithId orderId: OrderSummary.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).sellerFeedback()
    }
    
    
    public func loadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        let blFeedbacks = await BrickLinkAPIClient.fetchFeedbacks(forOrderWithId: orderId)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
        try! fileDataAccess.setOrderFeedbacks(feedbacks, forOrderId: orderId)
        try! fileDataAccess.save()
    }
    
    
    public func loadOrderFeedbacksIfMissing(forOrderWithId orderId: OrderSummary.ID) async {
        
        if !fileDataAccess.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func reloadOrderFeedbacks(forOrderWithId orderId: OrderSummary.ID) async {
        
        if fileDataAccess.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    public func postFeedback(forOrderWithId: OrderSummary.ID, rating: Int, comment: String) async {
        
        await BrickLinkAPIClient.postFeedback(forOrderWithId: forOrderWithId, rating: rating, comment: comment)
        
        await reloadOrderFeedbacks(forOrderWithId: forOrderWithId)
    }
    
    
    public var dateValidatedWithoutFeedbackByOrderId: [OrderSummary.ID: Date] {
        
        fileDataAccess.dateValidatedWithoutFeedbackByOrderId
    }
    
    
    public func validateOrderWithoutFeedback(orderId: OrderDetails.ID) {
        
        try! fileDataAccess.setDateValidatedWithoutFeedback(Date(), forOrderId: orderId)
        try! fileDataAccess.save()
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
