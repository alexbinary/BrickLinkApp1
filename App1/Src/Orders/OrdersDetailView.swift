
import SwiftUI



struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orderId: OrderDetails.ID
    
    @State private var columnWidth: CGFloat?
    
    
    var body: some View {
            
        VStack {
            
            if let order = appController.orderDetails(forOrderWithId: orderId),
               let orderSummary = appController.orderSummary(forOrderWithId: orderId) {
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Grid(alignment: .leading, verticalSpacing: 0) {
                                
                                GridRow {
                                    Text("order").cardCaption()
                                    Text("placed").cardCaption()
                                    
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
                                    Text("status").cardCaption()
                                    Text("changed").cardCaption()
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
                        .background(Color(nsColor: .quaternarySystemFill))
                        .border(Color(nsColor: .tertiarySystemFill))
                        .cornerRadius(6)
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HeaderTitleView(label: "􀼏 Status")
                                .padding(.bottom, 6)
                            
                            ScrollView {
                                
                                Grid(alignment: .leading) {
                                    
                                    let padding: CGFloat = 6
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistPayment(orderId))
                                        Text("Payment received")
                                    }
                                    
                                    Text(OrderBusinessStatus.validatePayment.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistIncomeTransaction(orderId))
                                        Text("Register transaction")
                                    }
                                    
                                    Text(OrderBusinessStatus.pickAndPack.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistPicking(orderId))
                                        Text("Pick items")
                                    }
                                    GridRow {
                                        checkStatus(appController.orderChecklistVerification(orderId))
                                        Text("Verify items")
                                    }
                                    GridRow {
                                        checkStatus(appController.orderChecklistPacked(orderId))
                                        Text("Pack order")
                                    }
                                    
                                    Text(OrderBusinessStatus.ship.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistShipped(orderId))
                                        Text("Mark Shipped")
                                    }
                                    
                                    Text(OrderBusinessStatus.validateShipping.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistTrackingNo(orderId))
                                        Text("Input tracking no")
                                    }
                                    GridRow {
                                        checkStatus(appController.orderChecklistDriveThru(orderId))
                                        Text("Send drive thru")
                                    }
                                    GridRow {
                                        checkStatus(appController.orderChecklistAffranchissement(orderId))
                                        Text("Validate stamping")
                                    }
                                    GridRow {
                                        checkStatus(appController.orderChecklistShippingTransaction(orderId))
                                        Text("Register transaction")
                                    }
                                    
                                    Text(OrderBusinessStatus.inTransit.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistReceived(orderId))
                                        Text("Received or Completed")
                                    }
                                    
                                    Text(OrderBusinessStatus.giveFeedback.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistSellerFeedback(orderId))
                                        Text("Give feedback")
                                    }
                                    
                                    Text(OrderBusinessStatus.done.descriptionWithPicto).checklistTitle()
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistUnchangedFor30Days(orderId))
                                        Text("Inactive for 30 days")
                                    }
                                    
                                    Text(OrderBusinessStatus.closed.descriptionWithPicto).checklistTitle()
                                        .padding(.top, padding)
                                }
                                
                                Spacer()
                            }
                            .scrollIndicators(.hidden)
                        }
                        .padding()
                        .equalWidths()
                        .frame(width: columnWidth, alignment: .leading)
                        .background(Color(nsColor: .quaternarySystemFill))
                        .border(Color(nsColor: .tertiarySystemFill))
                        .cornerRadius(6)
                        
                    }
                    .equalWidths($columnWidth)
                    
                    TabView(selection: .constant(2)) {
                        
                        ScrollView {
                            OrderDetailView(order: order)
                        }
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
                            OrderComptaView(order: order)
                        }
                        .padding()
                        .tabItem {
                            Text("􀖧 Compta")
                        }
                        .tag(4)
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
        
        await appController.forceRefreshOrder(orderId: orderId)
    }
    
    
    @ViewBuilder
    func checkStatus(_ status: Bool) -> some View {
        if status {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(red)
        }
    }
}



extension View {
    
    
    @ViewBuilder func checklistTitle() -> some View {
        
        self.font(.title3).opacity(0.5)
    }
}
