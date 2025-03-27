
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
        
        print("Loading order feedbacks \(order.id)")
        
        let blFeedbacks = await brickLinkAPIClient.fetchFeedbacks(orderId: order.id)
        let feedbacks = blFeedbacks.map { Feedback(fromBl: $0) }
        
        print("loaded \(feedbacks.count) feedbacks")
        
        try! dataStore.setOrderFeedbacks(feedbacks, forOrderId: order.id)
        try! dataStore.save()
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
    
    
    // MARK: - Post feedback
    
    
    func postFeedback(for order: Order, rating: FeedbackRating, comment: String) async {
        
        await brickLinkAPIClient.postFeedback(orderId: order.id, rating: rating.bricklinkFeedbackRating.rawValue, comment: comment)
        
        await reloadFeedbacks(for: order)
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
