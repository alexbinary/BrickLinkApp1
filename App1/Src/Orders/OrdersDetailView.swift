
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
                                        Text(order.id).font(.title2)
                                    }
                                    Text(order.date, format: .dateTime).font(.title3)
                                }
                                
                                GridRow {
                                    Text(order.status.rawValue).font(.title2)
                                    Text(orderSummary.dateStatusChanged, format: .dateTime).font(.title3)
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
                        .frame(width: columnWidth)
                        .background(Color(nsColor: .quaternarySystemFill))
                        .border(Color(nsColor: .tertiarySystemFill))
                        .cornerRadius(6)
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            HeaderTitleView(label: "􀼏 Status")
                            
                            Text(appController.orderBusinessStatus(order.id).rawValue).font(.title2)
                            
                            HeaderTitleView(label: "􀼏 Checklist")
                            
                            Grid(alignment: .leading) {
                                
                                GridRow {
                                    checkStatus(appController.orderChecklistPayment(orderId))
                                    Text("Payment")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistIncomeTransaction(orderId))
                                    Text("Income transaction")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistPicking(orderId))
                                    Text("Picked")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistVerification(orderId))
                                    Text("Verification")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistPacked(orderId))
                                    Text("Packed")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistShipped(orderId))
                                    Text("Shipped")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistTrackingNo(orderId))
                                    Text("Tracking no")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistDriveThru(orderId))
                                    Text("Drive thru")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistAffranchissement(orderId))
                                    Text("Affranchissement")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistShippingTransaction(orderId))
                                    Text("Shipping transaction")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistReceived(orderId))
                                    Text("Received")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistSellerFeedback(orderId))
                                    Text("Seller feedback")
                                }
                                GridRow {
                                    checkStatus(appController.orderChecklistUnchangedFor30Days(orderId))
                                    Text("Unchanged for 30+ days")
                                }
                            }
                            
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
