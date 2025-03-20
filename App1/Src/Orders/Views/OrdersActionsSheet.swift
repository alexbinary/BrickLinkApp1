
import SwiftUI


struct OrdersActionsSheet: View {
    
    
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
                            CheckView(checked: orderChecklistController.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        HStack {
                            CheckView(checked: orderChecklistController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionController.ordersThatNeedGiveFeedback, title: "Give feedback") { order in
                        HStack {
                            CheckView(checked: orderChecklistController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                    
                    sectionView(orders: orderActionController.ordersToShipAndSendDriveThru, title: "Ship and send DT") { order in
                        HStack {
                            CheckView(checked: orderChecklistController.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        HStack {
                            CheckView(checked: orderChecklistController.orderChecklistDriveThru(order.id))
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
    
    let controllers = AppController.createControllers()
    
    let orderChecklistController = controllers.orderChecklistController
    let orderActionController = controllers.orderActionController
    
    let orderController = controllers.orderController
    let orders = orderController.orderSummaries
    
    OrdersActionsSheet(orders: orders)
        .environment(orderChecklistController)
        .environment(orderActionController)
}
