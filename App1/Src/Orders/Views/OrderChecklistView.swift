
import SwiftUI



struct OrderChecklistView: View {

    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(PickingController.self)
    var pickingController
    
    @Environment(TrackingController.self)
    var trackingController
    
    @Environment(OrderChecklistController.self)
    var orderChecklistController
    
    
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
                        CheckStatusView(status: orderChecklistController.orderChecklistPayment(order.id))
                        Text("Payment received")
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistIncomeTransaction(order.id))
                        Text("Register transaction")
                    }

                    Text(OrderMacroStatus.pickAndPack.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistPicking(order.id))
                        let progress = pickingController.pickingProgress(forOrderWithId: order.id)
                        if progress == 100% {
                            Text("Pick items")
                        } else {
                            Text("Pick items - \(progress) complete")
                        }
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistVerification(order.id))
                        let progress = pickingController.pickingVerificationProgress(forOrderWithId: order.id)
                        if progress == 100% {
                            Text("Verify items")
                        } else {
                            Text("Verify items - \(progress) complete")
                        }
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistPacked(order.id))
                        Text("Pack order")
                    }

                    Text(OrderMacroStatus.ship.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistStamping(order.id))
                        Text("Validate stamping")
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistShippingTransaction(order.id))
                        Text("Register transaction")
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistTrackingNo(order.id))
                        Text("Input tracking no")
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistShipped(order.id))
                        Text("Mark Shipped")
                    }
                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistDriveThru(order.id))
                        Text("Send drive thru")
                    }
                    
                    Text("􀐚 Shipped").checklistTitle()
                        .padding(.vertical, padding)
                    
                    GridRow {
                        CheckStatusView(
                            status: trackingController.laPosteTrackingStatus(forOrderWithId: order.id)?.isOneOf(.inTransit, .delivered) ?? false,
                            mandatory: false
                        )
                        Text("Picked up by transported")
                    }

                    Text(OrderMacroStatus.inTransit.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistReceived(order.id))
                        Text("Received")
                    }

                    Text(OrderMacroStatus.received.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistCompleted(order.id))
                        Text("Completed")
                    }

                    GridRow {
                        CheckStatusView(
                            status: orderChecklistController.orderChecklistBuyerFeedback(order.id),
                            mandatory: false
                        )
                        Text("Buyer feedback")
                    }

                    Text(OrderMacroStatus.giveFeedback.descriptionWithPicto).checklistTitle()
                        .padding(.vertical, padding)

                    GridRow {
                        CheckStatusView(status: orderChecklistController.orderChecklistSellerFeedback(order.id))
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
    let orderStore = appController.orderStore
    let pickingController = appController.pickingController
    let trackingController = appController.trackingController
    let orderChecklistController = appController.orderChecklistController
    
    let order = orderStore.orderDetails.first!
    
    OrderChecklistView(order)
        .environment(orderStore)
        .environment(pickingController)
        .environment(trackingController)
        .environment(orderChecklistController)
}
