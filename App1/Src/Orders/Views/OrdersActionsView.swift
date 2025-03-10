
import SwiftUI


struct OrdersActionsView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let orders: [OrderSummary]
    
    
    var body: some View {
        
        Group {
            
            let ordersThatNeedCompletedAndGiveFeedback = app.ordersThatNeedCompletedAndGiveFeedback
            let ordersThatNeedGiveFeedback = app.ordersThatNeedGiveFeedback
            let ordersToShipAndSendDriveThru = app.ordersToShipAndSendDriveThru
            
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
                        Task { await app.performActionForAllOrders() }
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
    OrdersActionsView(orders: appController.orderSummaries)
        .environmentObject(appController)
}
