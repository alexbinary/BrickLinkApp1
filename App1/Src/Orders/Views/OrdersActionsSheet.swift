
import SwiftUI


struct OrdersActionsSheet: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    @Environment(OrderChecklistController.self)
    var orderChecklistController
    
    @Environment(OrderActionController.self)
    var orderActionController
    
    
    let orders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            if orderActionController.ordersThatNeedAction.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    sectionView(orders: orderActionController.ordersThatNeedCompletedAndGiveFeedback, title: "Complete & Give feedback") { order in
                        HStack {
                            CheckStatusView(status: orderChecklistController.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckStatusView(status: orderChecklistController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionController.ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckStatusView(status: orderChecklistController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionController.ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckStatusView(status: orderChecklistController.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        HStack {
                            CheckStatusView(status: orderChecklistController.orderChecklistDriveThru(order.id))
                            Text("Send drive thru")
                        }
                    }
                    
                    Button {
                        Task { await orderActionController.performActionForAllOrders() }
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
    let orderStore = appController.orderStore
    let orderChecklistController = appController.orderChecklistController
    let orderActionController = appController.orderActionController
    
    let orders = orderStore.orderSummaries
    
    OrdersActionsSheet(orders: orders)
        .environmentObject(appController)
        .environment(orderChecklistController)
        .environment(orderActionController)
}
