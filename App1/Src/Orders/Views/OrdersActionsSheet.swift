
import SwiftUI


struct OrdersActionsSheet: View {
    
    
    @EnvironmentObject var app: AppController
    
    let orders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            if app.ordersThatNeedAction.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    sectionView(orders: app.ordersThatNeedCompletedAndGiveFeedback, title: "Complete & Give feedback") { order in
                        HStack {
                            CheckStatusView(status: app.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckStatusView(status: app.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: app.ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckStatusView(status: app.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: app.ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckStatusView(status: app.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        HStack {
                            CheckStatusView(status: app.orderChecklistDriveThru(order.id))
                            Text("Send drive thru")
                        }
                    }
                    
                    Button {
                        Task { await app.performActionForAllOrders() }
                    } label: {
                        Text("Do all").padding(.horizontal)
                    }
                }
            }
        }
        .padding()
    }
    
    
    @ViewBuilder
    func sectionView(orders: [OrderSummary], title: String, @ViewBuilder content: @escaping (_ order: OrderSummary) -> some View) -> some View {
    
        if !orders.isEmpty {
            
            Text("\(title) (\(orders.count))").font(.title2)
            
            ForEach(orders) { order in
                
                GridRow(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(order.id)
                        Text(order.buyer)
                    }
                    VStack(alignment: .leading) {
                        content(order)
                    }
                }
                
                Divider()
            }
        }
    }
}


#Preview {
    let appController = AppController()
    OrdersActionsSheet(orders: appController.orderSummaries)
        .environmentObject(appController)
}
