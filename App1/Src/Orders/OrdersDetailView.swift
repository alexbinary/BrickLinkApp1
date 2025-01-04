
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
                            
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Link(destination: URL(string: "https://www.bricklink.com/orderDetail.asp?ID=\(order.id)#/")!) {
                                        Text(order.id).font(.title3)
                                    }
                                    Text(order.date, format: .dateTime)
                                }
                                
                                GridRow {
                                    Text(order.status.rawValue).font(.title3)
                                    Text(orderSummary.dateStatusChanged, format: .dateTime)
                                }
                            }
                            
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    Text("􀉩").gridColumnAlignment(.center)
                                    Text(order.buyer)
                                }
                                
                                GridRow {
                                    Text("􀍩").gridColumnAlignment(.center)
                                    
                                    HStack {
                                        Text("\(order.items) (\(order.lots))")
                                        Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
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
                            
                            ScrollView {
                                
                                Grid(alignment: .leading) {
                                    
                                    let padding: CGFloat = 4
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistPayment(orderId))
                                        Text("Payment received")
                                    }
                                    
                                    Text(OrderBusinessStatus.validatePayment.descriptionWithPicto).font(.title3)
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistIncomeTransaction(orderId))
                                        Text("Register transaction")
                                    }
                                    
                                    Text(OrderBusinessStatus.pickAndPack.descriptionWithPicto).font(.title3)
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
                                    
                                    Text(OrderBusinessStatus.ship.descriptionWithPicto).font(.title3)
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistShipped(orderId))
                                        Text("Mark Shipped")
                                    }
                                    
                                    Text(OrderBusinessStatus.validateShipping.descriptionWithPicto).font(.title3)
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
                                    
                                    Text(OrderBusinessStatus.inTransit.descriptionWithPicto).font(.title3)
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistReceived(orderId))
                                        Text("Received or Completed")
                                    }
                                    
                                    Text(OrderBusinessStatus.giveFeedback.descriptionWithPicto).font(.title3)
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistSellerFeedback(orderId))
                                        Text("Give feedback")
                                    }
                                    
                                    Text(OrderBusinessStatus.done.descriptionWithPicto).font(.title3)
                                        .padding(.vertical, padding)
                                    
                                    GridRow {
                                        checkStatus(appController.orderChecklistUnchangedFor30Days(orderId))
                                        Text("Inactive for 30 days")
                                    }
                                    
                                    Text(OrderBusinessStatus.closed.descriptionWithPicto).font(.title3)
                                        .padding(.top, padding)
                                }
                            }
                            .scrollIndicators(.hidden)
                            
                            Spacer()
                        }
                        .padding()
                        .equalWidths()
                        .frame(width: columnWidth, alignment: .leading)
                        .background(Color(nsColor: .quaternarySystemFill))
                        .border(Color(nsColor: .tertiarySystemFill))
                        .cornerRadius(6)
                        
                    }
                    .equalWidths($columnWidth)
                    
                    TabView {
                        
                        ScrollView {
                            OrderDetailView(order: order)
                        }
                        .padding()
                        .tabItem {
                            Text("Details & Actions")
                        }
                        .tag(0)
                        
                        OrderPickingView(orderId: orderId)
                            .tabItem {
                                Text("Picking")
                            }
                            .tag(1)
                        
                        ScrollView {
                            OrderPackingAndShippingView(orderId: orderId)
                        }
                        .tabItem {
                            Text("Packing & Shipping")
                        }
                        .tag(2)
                        
                        ScrollView {
                            OrderComptaView(order: order)
                        }
                        .padding()
                        .tabItem {
                            Text("Compta")
                        }
                        .tag(3)
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
