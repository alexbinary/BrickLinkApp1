
import SwiftUI



struct OrderFeedbackView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            if let order = appController.orderDetails(forOrderWithId: orderId) {
                
                let orderFeedbacks = appController.orderFeedbacks(forOrderWithId: order.id)
                
                Table(orderFeedbacks.sorted { $0.dateRated < $1.dateRated }) {
                    TableColumn("From", value: \.from)
                    TableColumn("Rating") { feedback in
                        
                        let rating = feedback.rating
                        if rating == 0 {
                            Text("􀉿")
                        } else if rating == 2 {
                            Text("􀊁")
                        } else {
                            Text("Neutral")
                        }
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
                            await appController.postPraiseOrderFeedback(orderId: order.id)
                        }
                    } label: {
                        Text("Post Praise feedback")
                    }
                    Button {
                        self.appController.validateOrderWithoutFeedback(orderId: order.id)
                    } label: {
                        Text("Validate without feedback")
                    }
                    if let date = appController.dateOrderValidatedWithoutFeedback(orderId: order.id) {
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
        
        await appController.loadOrderDetailsIfMissing(forOrderWithId: orderId)
    }
}
