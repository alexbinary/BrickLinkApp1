
import SwiftUI



struct OrderFeedbackView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            if let order = app.orderDetails(forOrderWithId: orderId) {
                
                let orderFeedbacks = app.orderFeedbacks(forOrderWithId: order.id)
                
                Table(orderFeedbacks.sorted { $0.dateRated < $1.dateRated }) {
                    TableColumn("From", value: \.from)
                    TableColumn("Rating") { feedback in
                        FeedbackRatingView(feedback)
                    }
                    TableColumn("Comment", value: \.comment)
                    TableColumn("Date") { feedback in
                        Text(feedback.dateRated, format: .dateTime)
                    }
                }
                .frame(minHeight: 100)
                
                HStack {
                    Button {
                        Task {
                            await app.postPraiseOrderFeedback(orderId: order.id)
                        }
                    } label: {
                        Text("Post Praise feedback")
                    }
                    Button {
                        self.app.validateOrderWithoutFeedback(orderId: order.id)
                    } label: {
                        Text("Validate without feedback")
                    }
                    if let date = app.dateOrderValidatedWithoutFeedback(orderId: order.id) {
                        Text("Validated without feedback on")
                        Text(date, format: .dateTime)
                    }
                }
            }
        }
        .padding()
        .task {
            await loadOrder()
        }
        .onChange(of: orderId) { oldValue, newValue in
            Task {
                await loadOrder()
            }
        }
    }
    
    
    func loadOrder() async {
        
        await app.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
}
