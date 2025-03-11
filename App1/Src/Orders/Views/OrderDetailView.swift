
import SwiftUI



struct OrderDetailView: View {
    
    
    @EnvironmentObject var app: AppController
    
    let orderId: OrderDetails.ID
    
    @State private var columnWidth: CGFloat?
    
    
    var body: some View {
            
        VStack {
            
            if let order = app.orderDetails(forOrderWithId: orderId),
               let orderSummary = app.orderSummary(forOrderWithId: orderId) {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Grid(alignment: .leading, verticalSpacing: 0) {
                                
                                GridRow {
                                    Text("order").captionSyle()
                                    Text("placed").captionSyle()
                                    
                                }
                                GridRow {
                                    Link(destination: URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(order.id)#/")!) {
                                        Text(order.id).font(.title2)
                                    }
                                    .monospacedDigit()
                                    Text(order.date, format: .dateTime)
                                        .frame(width: 150, alignment: .leading)
                                        .monospacedDigit()
                                }
                            
                                GridRow {
                                    Text("status").captionSyle()
                                    Text("changed").captionSyle()
                                }
                                GridRow {
                                    Text(order.status.rawValue).font(.title3)
                                    Text(orderSummary.dateStatusChanged, format: .dateTime)
                                        .monospacedDigit()
                                }
                            }
                            
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Text("􀉩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                                    Text(order.buyer)
                                }
                                
                                GridRow {
                                    Text("􀍩").foregroundStyle(.secondary).gridColumnAlignment(.center)
                                    
                                    HStack {
                                        Text("\(order.items) (\(order.lots))")
                                            .frame(width: 75, alignment: .leading)
                                        HStack {
                                            Text("􀖧").foregroundStyle(.secondary)
                                            Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
                                                .monospacedDigit()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        .equalWidths()
                        .frame(width: columnWidth, alignment: .leading)
                        .roundedContainer(style: .primary)
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HeaderTitleView(label: "􀼏 Status")
                                .padding(.bottom, 6)
                            
                            ScrollView {
                                
                                Grid(alignment: .leading) {
                                    
                                    let padding: CGFloat = 6
                                    
                                    Text(OrderMacroStatus.validatePayment.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistPayment(orderId))
                                        Text("Payment received")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistIncomeTransaction(orderId))
                                        Text("Register transaction")
                                    }

                                    Text(OrderMacroStatus.pickAndPack.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)

                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistPicking(orderId))
                                        
                                        let picked = app.pickedItems(forOrderWithId: orderId).count
                                        let total = app.orderItems(forOrderWithId: orderId).count
                                        
                                        
                                        if picked == total {
                                            Text("Pick items")
                                        } else {
                                            let percent = floor(Double(picked)/Double(total)*100)
                                            Text(String(format: "Pick items - %3.0f%% complete", percent))
                                        }
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistVerification(orderId))
                                        
                                        let verified = app.verifiedItems(forOrderWithId: orderId).count
                                        let total = app.orderItems(forOrderWithId: orderId).count
                                        
                                        if verified == total {
                                            Text("Verify items")
                                        } else {
                                            let percent = floor(Double(verified)/Double(total)*100)
                                            Text(String(format: "Verify items - %3.0f%% complete", percent))
                                        }
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistPacked(orderId))
                                        Text("Pack order")
                                    }

                                    Text(OrderMacroStatus.ship.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)

                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistStamping(orderId))
                                        Text("Validate stamping")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistShippingTransaction(orderId))
                                        Text("Register transaction")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistTrackingNo(orderId))
                                        Text("Input tracking no")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistShipped(orderId))
                                        Text("Mark Shipped")
                                    }
                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistDriveThru(orderId))
                                        Text("Send drive thru")
                                    }
                                    
                                    Text("􀐚 Shipped").checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        CheckStatusView(
                                            status: app.laPosteTrackingStatus(forOrderWithId: orderId)?.isOneOf(.inTransit, .delivered) ?? false,
                                            mandatory: false
                                        )
                                        Text("Picked up by transported")
                                    }

                                    Text(OrderMacroStatus.inTransit.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)

                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistReceived(orderId))
                                        Text("Received")
                                    }

                                    Text(OrderMacroStatus.received.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)

                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistCompleted(orderId))
                                        Text("Completed")
                                    }

                                    GridRow {
                                        CheckStatusView(
                                            status: app.orderChecklistBuyerFeedback(orderId),
                                            mandatory: false
                                        )
                                        Text("Buyer feedback")
                                    }

                                    Text(OrderMacroStatus.giveFeedback.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)

                                    GridRow {
                                        CheckStatusView(status: app.orderChecklistSellerFeedback(orderId))
                                        Text("Give feedback")
                                    }
                                    
                                    Text(OrderMacroStatus.closed.descriptionWithPicto).checklistTitle()
                                        .padding(.top, padding)
                                }
                                
                                Spacer()
                            }
                            .scrollIndicators(.hidden)
                        }
                        .padding()
                        .equalWidths()
                        .frame(width: columnWidth, alignment: .leading)
                        .roundedContainer(style: .primary)
                        
                    }
                    .equalWidths($columnWidth)
                    
                    TabView {
                        
                        OrderGeneralView(order: order)
                        .padding()
                        .tabItem {
                            Text("􀅴 General")
                        }
                        .tag(0)
                        
                        OrderPickingView(orderId: orderId)
                            .tabItem {
                                Text("􀈥 Picking")
                            }
                            .tag(1)
                        
                        ScrollView {
                            OrderShippingView(orderId: orderId)
                        }
                        .tabItem {
                            Text("􀐚 Shipping")
                        }
                        .tag(2)
                        
                        ScrollView {
                            OrderFeedbackView(orderId: orderId)
                        }
                        .tabItem {
                            Text("􀉿 Feedback")
                        }
                        .tag(3)
                        
                        ScrollView {
                            OrderRefundView(order: order)
                        }
                        .padding()
                        .tabItem {
                            Text("􂈚 Refunds")
                        }
                        .tag(4)
                        
                        ScrollView {
                            OrderComptaView(order: order)
                        }
                        .padding()
                        .tabItem {
                            Text("􀖧 Compta")
                        }
                        .tag(5)
                    }
                }
                
            } else {
                
                Text("loading order...")
            }
        }
        .padding()
        .task {
            await refreshOrder()
        }
        .onChange(of: orderId) { oldValue, newValue in
            Task {
                await refreshOrder()
            }
        }
        .navigationTitle("Order \(orderId)")
    }
    
    
    func refreshOrder() async {
        
        await app.forceRefreshOrder(orderId: orderId)
    }
}



extension View {
    
    
    @ViewBuilder func checklistTitle() -> some View {
        
        self.font(.title3).opacity(0.5)
    }
}
