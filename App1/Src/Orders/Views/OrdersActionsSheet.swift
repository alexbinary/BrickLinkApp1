
import SwiftUI



struct OrdersActionsSheet: View {
    
    
    @Environment(\.orderStore)
    var orderStore: OrderStoreProtocol!
    
    
    let orders: [Order]
    
    var ordersThatNeedAction: [Order] {
        
        orderStore.ordersThatNeedAction(orders)
    }
    
    var ordersThatNeedCompletedAndGiveFeedback: [Order] {
        
        orderStore.ordersThatNeedCompletedAndGiveFeedback(orders)
    }
    
    var ordersThatNeedGiveFeedback: [Order] {
        
        orderStore.ordersThatNeedGiveFeedback(orders)
    }
    
    var ordersToShipAndSendDriveThru: [Order] {
        
        orderStore.ordersToShipAndSendDriveThru(orders)
    }
    
    
    var body: some View {
        
        Group {
            
            if ordersThatNeedAction.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    sectionView(orders: ordersThatNeedCompletedAndGiveFeedback, title: "Complete & Give feedback") { order in
                        HStack {
                            CheckView(state: orderStore.state(of: .completed, for: order))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckView(state: orderStore.state(of: .sellerFeedback, for: order))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckView(state: orderStore.state(of: .sellerFeedback, for: order))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckView(state: orderStore.state(of: .shipped, for: order))
                            Text("Mark shipped")
                            if orderStore.isUpdatingStatus(of: order, to: .shipped) {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                        HStack {
                            CheckView(state: orderStore.state(of: .driveThru, for: order))
                            Text("Send drive thru")
                            if orderStore.isSendingDriveThru(for: order) {
                                ProgressView()
                                    .controlSize(.small)
                            }
                        }
                    }
                    
                    Button {
                        Task { await orderStore.performActions(for: orders) }
                    } label: {
                        Text("Do all").padding(.horizontal)
                    }
                }
            }
        }
        .padding()
    }
    
    
    @ViewBuilder
    func sectionView(orders: [Order], title: String, @ViewBuilder content: @escaping (_ order: Order) -> some View) -> some View {
    
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
    let orders = env.stores.order.orders
    
    OrdersActionsSheet(orders: orders)
        .inject(env)
}
