
import SwiftUI



struct OrderDetailFeedbackView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let order: OrderDetails
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            let orderFeedbacks = app.orderFeedbacks(forOrderWithId: order.id)
            Table(orderFeedbacks.sorted { $0.dateRated < $1.dateRated }) {
                
                TableColumn("From", value: \.from)
                TableColumn("Rating") { FeedbackRating($0) }
                TableColumn("Comment", value: \.comment)
                TableColumn("Date") { Text($0.dateRated, format: .dateTime) }
            }
            .frame(minHeight: 100)
            
            HStack {
                Button("Post Praise feedback") {
                    Task { await app.postPraiseOrderFeedback(orderId: order.id) }
                }
                Button("Validate without feedback") {
                    app.validateOrderWithoutFeedback(orderId: order.id)
                }
                if let date = app.dateOrderValidatedWithoutFeedback(orderId: order.id) {
                    Text("Validated without feedback on")
                    Text(date, format: .dateTime)
                }
            }
        }
        .padding()
    }
}
