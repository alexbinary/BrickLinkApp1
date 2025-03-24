
import SwiftUI



struct OrderDetailFeedbackView: View {
    
    
    @Environment(FeedbackUserStore.self)
    var feedbackStore
    
    @Environment(FeedbackController.self)
    var feedbackController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            let feedbacks = feedbackStore.feedbacks(forOrderWithId: order.id)
            Table(feedbacks.sorted { $0.dateRated < $1.dateRated }) {
                
                TableColumn("From", value: \.from)
                TableColumn("Rating") { FeedbackRating($0) }
                TableColumn("Comment", value: \.comment)
                TableColumn("Date") { Text($0.dateRated, format: .dateTime) }
            }
            .frame(minHeight: 100)
            
            HStack {
                Button("Post Praise feedback") { Task {
                    await feedbackController.postPraiseFeedback(forOrderWithId: order.id)
                }}
                Button("Validate without feedback") {
                    feedbackController.validateOrderWithoutFeedback(orderId: order.id)
                }
                if feedbackController.orderIsValidatedWithoutFeedback(orderId: order.id) {
                    Text("Validated without feedback on")
                    let date = feedbackController.dateOrderValidatedWithoutFeedback(orderId: order.id)!
                    Text(date, format: .dateTime)
                }
            }
        }
        .padding()
    }
}
