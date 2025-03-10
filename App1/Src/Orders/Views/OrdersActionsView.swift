
import SwiftUI


struct OrdersActionsView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let allOrders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            let ordersThatNeedCompletedAndGiveFeedback = allOrders
                .filter { app.macroStatus(forOrderWithId: $0.id) == .inTransit && app.orderChecklistUnchangedFor30Days($0.id) }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            let ordersThatNeedGiveFeedback = allOrders
                .filter { app.macroStatus(forOrderWithId: $0.id) == .giveFeedback }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            let ordersToShipAndSendDriveThru = allOrders
                .filter {
                    app.macroStatus(forOrderWithId: $0.id) == .ship
                    && app.orderChecklistStamping($0.id)
                    && app.orderChecklistShippingTransaction($0.id)
                    && app.orderChecklistTrackingNo($0.id)
                }
                .sorted { $0.date > $1.date }
            
            if ordersThatNeedCompletedAndGiveFeedback.isEmpty,
               ordersThatNeedGiveFeedback.isEmpty,
               ordersToShipAndSendDriveThru.isEmpty {
                
                Text("All orders ok")
                
            } else {
                
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    if !ordersThatNeedCompletedAndGiveFeedback.isEmpty {
                        
                        Text("Complete & Give feedback (\(ordersThatNeedCompletedAndGiveFeedback.count))")
                            .font(.title2)
                        
                        ForEach(ordersThatNeedCompletedAndGiveFeedback) { order in
                            
                            GridRow(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(order.id)
                                    Text(order.buyer)
                                }
                                Grid(alignment: .leading) {
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistCompleted(order.id))
                                        Text("Mark completed")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistSellerFeedback(order.id))
                                        Text("Give feedback")
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    if !ordersThatNeedGiveFeedback.isEmpty {
                        
                        Text("Give feedback (\(ordersThatNeedGiveFeedback.count))")
                            .font(.title2)
                        
                        ForEach(ordersThatNeedGiveFeedback) { order in
                            
                            GridRow(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(order.id)
                                    Text(order.buyer)
                                }
                                Grid(alignment: .leading) {
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistSellerFeedback(order.id))
                                        Text("Give feedback")
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    if !ordersToShipAndSendDriveThru.isEmpty {
                        
                        Text("Ship and send DT (\(ordersToShipAndSendDriveThru.count))")
                            .font(.title2)
                        
                        ForEach(ordersToShipAndSendDriveThru) { order in
                            
                            GridRow(alignment: .top) {
                                VStack(alignment: .leading) {
                                    Text(order.id)
                                    Text(order.buyer)
                                }
                                Grid(alignment: .leading) {
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistShipped(order.id))
                                        Text("Mark shipped")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistDriveThru(order.id))
                                        Text("Send drive thru")
                                    }
                                }
                            }
                            
                            Divider()
                        }
                    }
                    
                    Button {
                        Task {
                            for order in ordersThatNeedCompletedAndGiveFeedback {
                                await app.updateOrderStatus(orderId: order.id, status: .completed)
                                await app.postPraiseOrderFeedback(orderId: order.id)
                            }
                            for order in ordersThatNeedGiveFeedback {
                                await app.postPraiseOrderFeedback(orderId: order.id)
                            }
                            for order in ordersToShipAndSendDriveThru {
                                await app.updateOrderStatus(orderId: order.id, status: .shipped)
                                await app.sendDriveThru(orderId: order.id)
                            }
                        }
                    } label: {
                        Text("Do all").padding(.horizontal)
                    }
                }
            }
        }
        .padding()
    }
}


#Preview {
    let appController = AppController()
    OrdersActionsView(allOrders: appController.orderSummaries)
        .environmentObject(appController)
}
