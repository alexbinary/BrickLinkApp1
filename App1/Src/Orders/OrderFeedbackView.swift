
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
                
                Button {
                    Task {
                        await appController.postOrderFeedback(
                            orderId: order.id, rating: 0,
                            comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
                        )
                    }
                } label: {
                    Text("Post Praise feedback")
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
