
import SwiftUI



struct OrderDetailFeedbackView: View {
    
    
    @Environment(FeedbackStore.self)
    var feedbackStore
    
    
    let order: Order
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            let feedbacks = feedbackStore.feedbacks(for: order)
            Table(feedbacks.sorted { $0.dateRated < $1.dateRated }) {
                
                TableColumn("From", value: \.from)
                TableColumn("Rating") { FeedbackRatingView($0) }
                TableColumn("Comment", value: \.comment)
                TableColumn("Date") { Text($0.dateRated, format: .dateTime) }
            }
            .frame(minHeight: 100)
            
            HStack {
                Button("Post Praise feedback") { Task {
                    await feedbackStore.postPraiseFeedback(for: order)
                }}
                Button("Validate without feedback") {
                    feedbackStore.validateOrderWithoutFeedback(order)
                }
                if feedbackStore.orderIsValidatedWithoutFeedback(order) {
                    Text("Validated without feedback on")
                    let date = feedbackStore.dateOrderValidatedWithoutFeedback(order)!
                    Text(date, format: .dateTime)
                }
                if feedbackStore.isLoadingFeedbacks(for: order) {
                    Text("updating...")
                }
            }
        }
        .padding()
        .task { await feedbackStore.softRefreshFeedbacks(for: order) }
    }
}
