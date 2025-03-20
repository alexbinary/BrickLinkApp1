
import SwiftUI


struct OrdersActionsSheet: View {
    
    
    @Environment(OrderChecklistStore.self)
    var orderChecklistStore
    
    @Environment(OrderActionStore.self)
    var orderActionStore
    
    
    let orders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            if orderActionStore.ordersThatNeedAction.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    sectionView(orders: orderActionStore.ordersThatNeedCompletedAndGiveFeedback, title: "Complete & Give feedback") { order in
                        HStack {
                            CheckView(checked: orderChecklistStore.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckView(checked: orderChecklistStore.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionStore.ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckView(checked: orderChecklistStore.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionStore.ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckView(checked: orderChecklistStore.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        HStack {
                            CheckView(checked: orderChecklistStore.orderChecklistDriveThru(order.id))
                            Text("Send drive thru")
                        }
                    }
                    
                    Button {
                        Task { await orderActionStore.performActionForAllOrders() }
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
    
    let stores = createStores()
    
    let orderChecklistStore = stores.orderChecklist
    let orderActionStore = stores.orderAction
    
    let orderStore = stores.order
    let orders = orderStore.orderSummaries
    
    OrdersActionsSheet(orders: orders)
        .environment(orderChecklistStore)
        .environment(orderActionStore)
}
