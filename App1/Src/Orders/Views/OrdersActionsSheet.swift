
import SwiftUI
import Core


struct OrdersActionsSheet: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let orders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            if orderStore.ordersThatNeedAction.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    sectionView(orders: orderStore.ordersThatNeedCompletedAndGiveFeedback, title: "Complete & Give feedback") { order in
                        HStack {
                            CheckView(checked: orderStore.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckView(checked: orderStore.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderStore.ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckView(checked: orderStore.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderStore.ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckView(checked: orderStore.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        HStack {
                            CheckView(checked: orderStore.orderChecklistDriveThru(order.id))
                            Text("Send drive thru")
                        }
                    }
                    
                    Button {
                        Task { await orderStore.performActionForAllOrders() }
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
    
    let env = createEnv()
    let orders = env.stores.order.orderSummaries
    
    OrdersActionsSheet(orders: orders)
        .inject(env)
}
