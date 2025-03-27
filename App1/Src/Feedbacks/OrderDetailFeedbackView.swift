
import SwiftUI
import Core



struct OrderDetailFeedbackView: View {
    
    
    @Environment(FeedbackStore.self)
    var feedbackStore
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            let feedbacks = feedbackStore.feedbacks(forOrderWithId: order.id)
            Table(feedbacks.sorted { $0.dateRated < $1.dateRated }) {
                
                TableColumn("From", value: \.from)
                TableColumn("Rating") { FeedbackRatingView($0) }
                TableColumn("Comment", value: \.comment)
                TableColumn("Date") { Text($0.dateRated, format: .dateTime) }
            }
            .frame(minHeight: 100)
            
            HStack {
                Button("Post Praise feedback") { Task {
                    await feedbackStore.postPraiseFeedback(forOrderWithId: order.id)
                }}
                Button("Validate without feedback") {
                    feedbackStore.validateOrderWithoutFeedback(orderId: order.id)
                }
                if feedbackStore.orderIsValidatedWithoutFeedback(orderId: order.id) {
                    Text("Validated without feedback on")
                    let date = feedbackStore.dateOrderValidatedWithoutFeedback(orderId: order.id)!
                    Text(date, format: .dateTime)
                }
            }
        }
        .padding()
    }
}
