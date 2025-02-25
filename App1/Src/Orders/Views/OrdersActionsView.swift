
import SwiftUI


struct OrdersActionsView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let allOrders: [OrderSummary]
    
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            let ordersThatNeedCompletedAndGiveFeedback = allOrders
                .filter { appController.orderBusinessStatus($0.id) == .inTransit && appController.orderChecklistUnchangedFor30Days($0.id) }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            ForEach(ordersThatNeedCompletedAndGiveFeedback) { order in
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(order.id)
                        Text(order.buyer)
                    }
                    Grid(alignment: .leading) {
                        GridRow {
                            CheckStatusView(status: appController.orderChecklistCompleted(order.id))
                            Text("Mark completed")
                        }
                        GridRow {
                            CheckStatusView(status: appController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                }
            }
            
            if !ordersThatNeedCompletedAndGiveFeedback.isEmpty {
                Button {
                    Task {
                        for order in ordersThatNeedCompletedAndGiveFeedback {
                            await appController.updateOrderStatus(orderId: order.id, status: .completed)
                            await appController.postPraiseOrderFeedback(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Complete & Give feedback (\(ordersThatNeedCompletedAndGiveFeedback.count))").padding(.horizontal)
                }
            }
            
            let ordersThatNeedGiveFeedback = allOrders
                .filter { appController.orderBusinessStatus($0.id) == .giveFeedback }
                .sorted { $0.dateStatusChanged > $1.dateStatusChanged }
            
            ForEach(ordersThatNeedGiveFeedback) { order in
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(order.id)
                        Text(order.buyer)
                    }
                    Grid(alignment: .leading) {
                        GridRow {
                            CheckStatusView(status: appController.orderChecklistSellerFeedback(order.id))
                            Text("Give feedback")
                        }
                    }
                }
            }
            
            if !ordersThatNeedGiveFeedback.isEmpty {
                Button {
                    Task {
                        for order in ordersThatNeedGiveFeedback {
                            await appController.postPraiseOrderFeedback(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Give feedback (\(ordersThatNeedGiveFeedback.count))").padding(.horizontal)
                }
            }
            
            let ordersToShipAndSendDriveThru = allOrders
                .filter {
                    appController.orderBusinessStatus($0.id) == .ship
                    && appController.orderChecklistStamping($0.id)
                    && appController.orderChecklistShippingTransaction($0.id)
                    && appController.orderChecklistTrackingNo($0.id)
                }
                .sorted { $0.date > $1.date }
            
            ForEach(ordersToShipAndSendDriveThru) { order in
                
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        Text(order.id)
                        Text(order.buyer)
                    }
                    Grid(alignment: .leading) {
                        GridRow {
                            CheckStatusView(status: appController.orderChecklistShipped(order.id))
                            Text("Mark shipped")
                        }
                        GridRow {
                            CheckStatusView(status: appController.orderChecklistDriveThru(order.id))
                            Text("Send drive thru")
                        }
                    }
                }
                
                Divider()
            }
            
            if !ordersToShipAndSendDriveThru.isEmpty {
                Button {
                    Task {
                        for order in ordersToShipAndSendDriveThru {
                            await appController.updateOrderStatus(orderId: order.id, status: .shipped)
                            await appController.sendDriveThru(orderId: order.id)
                        }
                    }
                } label: {
                    Text("Ship and send DT (\(ordersToShipAndSendDriveThru.count))").padding(.horizontal)
                }
            }
            
            if ordersThatNeedCompletedAndGiveFeedback.isEmpty,
               ordersThatNeedGiveFeedback.isEmpty,
               ordersToShipAndSendDriveThru.isEmpty {
                
                Text("All orders ok")
            }
        }
        .padding()
    }
}


#Preview {
    
    let dataFileUrl = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("/data/data.json5"))
    let dataStore = DataStore(dataFileUrl: dataFileUrl)
    
    let blCredentials = BrickLinkAPICredentials(
        
        consumerKey: Secrets.BrickLink.consumerKey,
        consumerSecret: Secrets.BrickLink.consumerSecret,
        
        tokenValue: Secrets.BrickLink.tokenValue,
        tokenSecret: Secrets.BrickLink.tokenSecret
    )
    
    let appController = AppController(
        dataStore: dataStore, blCredentials: blCredentials
    )
    
    OrdersActionsView(allOrders: appController.orderSummaries)
        .environmentObject(appController)
}
