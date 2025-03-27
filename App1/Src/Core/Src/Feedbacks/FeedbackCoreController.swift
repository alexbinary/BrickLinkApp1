
import Foundation



@MainActor
class FeedbackCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Read feedbacks
    
    
    func feedbacks(forOrderWithId orderId: Order.ID) -> [Feedback] {
        
        dataStore.orderFeedbacksByOrderId[orderId] ?? []
    }
    
    
    func buyerFeedback(forOrderWithId orderId: Order.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).buyerFeedback()
    }
    
    
    func sellerFeedback(forOrderWithId orderId: Order.ID) -> Feedback? {
        
        feedbacks(forOrderWithId: orderId).sellerFeedback()
    }
    
    
    func loadOrderFeedbacks(forOrderWithId orderId: Order.ID) async {
        
        print("Loading order feedbacks \(orderId)")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(forOrderWithId: orderId)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func loadOrderFeedbacksIfMissing(forOrderWithId orderId: Order.ID) async {
        
        if !dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    func reloadOrderFeedbacks(forOrderWithId orderId: Order.ID) async {
        
        if dataStore.orderFeedbacksByOrderId.keys.contains(orderId) {
            
            await loadOrderFeedbacks(forOrderWithId: orderId)
        }
    }
    
    
    // MARK: - Post feedback
    
    
    func postFeedback(forOrderWithId: Order.ID, rating: FeedbackRating, comment: String) async {
        
        await brickLinkAPIClient.postFeedback(forOrderWithId: forOrderWithId, rating: rating.bricklinkFeedbackRating.rawValue, comment: comment)
        
        await reloadOrderFeedbacks(forOrderWithId: forOrderWithId)
    }
    
    
    // MARK: - Validation without feedback
    
    
    var dateValidatedWithoutFeedbackByOrderId: [Order.ID: Date] {
        
        dataStore.dateValidatedWithoutFeedbackByOrderId
    }
    
    
    func validateOrderWithoutFeedback(orderId: Order.ID) {
        
        try! dataStore.setDateValidatedWithoutFeedback(Date(), forOrderId: orderId)
        try! dataStore.save()
    }
    
    
    func dateOrderValidatedWithoutFeedback(orderId: Order.ID) -> Date? {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId]
    }
    
    
    func orderIsValidatedWithoutFeedback(orderId: Order.ID) -> Bool {
        
        return dateValidatedWithoutFeedbackByOrderId[orderId] != nil
    }
}



extension Feedback {
    
    
    init(fromBl bl: BrickLinkOrderFeedback) {
        self.init(
            id: bl.feedbackId,
            orderId: "\(bl.orderId)",
            from: bl.from,
            to: bl.to,
            dateRated: bl.dateRated,
            rating: FeedbackRating(fromBl: bl.rating),
            author: FeedbackAuthor(fromBl: bl.ratingOfBs)!,
            comment: bl.comment
        )
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



extension FeedbackRating {
    
    
    
    init(fromBl bl: BrickLinkFeedbackRating) {
        switch bl {
        case .praise: self = .praise
        case .neutral: self = .neutral
        case .complaint: self = .complaint
        }
    }
    
    
    var bricklinkFeedbackRating: BrickLinkFeedbackRating {
        switch self {
        case .praise: .praise
        case .neutral: .neutral
        case .complaint: .complaint
        }
    }
}
