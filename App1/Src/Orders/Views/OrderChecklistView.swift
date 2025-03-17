
import SwiftUI



struct OrderChecklistView: View {

    
    @EnvironmentObject
    var app: AppController
    
    @Environment(OrderStore.self)
    var orderStore
    
    
    let order: OrderDetails
    var orderSummary: OrderSummary { orderStore.orderSummary(forOrderWithId: order.id)! }
    
    init(_ order: OrderDetails) {
        self.order = order
    }
    
    
    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􀼏 Status").padding(.bottom, 6)
            
            ScrollView {
                
                Grid(alignment: .leading) {
                    
                    let padding: CGFloat = 6
                    
                    Text(OrderMacroStatus.validatePayment.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)
                    
                    GridRow {
                        CheckStatusView(status: app.orderChecklistPayment(order.id))
                        Text("Payment received")
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistIncomeTransaction(order.id))
                        Text("Register transaction")
                    }

                    Text(OrderMacroStatus.pickAndPack.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: app.orderChecklistPicking(order.id))
                        let progress = app.pickingProgress(forOrderWithId: order.id)
                        if progress == 100% {
                            Text("Pick items")
                        } else {
                            Text("Pick items - \(progress) complete")
                        }
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistVerification(order.id))
                        let progress = app.pickingVerificationProgress(forOrderWithId: order.id)
                        if progress == 100% {
                            Text("Verify items")
                        } else {
                            Text("Verify items - \(progress) complete")
                        }
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistPacked(order.id))
                        Text("Pack order")
                    }

                    Text(OrderMacroStatus.ship.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: app.orderChecklistStamping(order.id))
                        Text("Validate stamping")
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistShippingTransaction(order.id))
                        Text("Register transaction")
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistTrackingNo(order.id))
                        Text("Input tracking no")
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistShipped(order.id))
                        Text("Mark Shipped")
                    }
                    GridRow {
                        CheckStatusView(status: app.orderChecklistDriveThru(order.id))
                        Text("Send drive thru")
                    }
                    
                    Text("􀐚 Shipped").checklistTitle()
                        .padding(.vertical, padding)
                    
                    GridRow {
                        CheckStatusView(
                            status: app.laPosteTrackingStatus(forOrderWithId: order.id)?.isOneOf(.inTransit, .delivered) ?? false,
                            mandatory: false
                        )
                        Text("Picked up by transported")
                    }

                    Text(OrderMacroStatus.inTransit.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: app.orderChecklistReceived(order.id))
                        Text("Received")
                    }

                    Text(OrderMacroStatus.received.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: app.orderChecklistCompleted(order.id))
                        Text("Completed")
                    }

                    GridRow {
                        CheckStatusView(
                            status: app.orderChecklistBuyerFeedback(order.id),
                            mandatory: false
                        )
                        Text("Buyer feedback")
                    }

                    Text(OrderMacroStatus.giveFeedback.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: app.orderChecklistSellerFeedback(order.id))
                        Text("Give feedback")
                    }
                    
                    Text(OrderMacroStatus.closed.descriptionWithPicto).checklistTitle()
                        .padding(.top, padding)
                }
                
                Spacer()
            }
            .scrollIndicators(.hidden)
        }
    }
}



extension View {
    
    
    @ViewBuilder func checklistTitle() -> some View {
        
        self.font(.title3).opacity(0.5)
    }
}



#Preview {
    let appController = AppController()
    let order = appController.orderDetails.first!
    OrderChecklistView(order)
        .environmentObject(appController)
}
