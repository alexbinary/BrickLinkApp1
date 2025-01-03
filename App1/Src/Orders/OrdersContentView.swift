
import SwiftUI


struct OrdersContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var ordersActiveNavigationPath: [OrderSummary.ID]
    
    
    var body: some View {
        
        ScrollView {
            
            LazyVStack(spacing: 12, pinnedViews: .sectionHeaders) {
                
                ForEach(appController.orderSummaries.grouppedByMonth, id: \.month) { item in
                    
                    Section {
                        
                        ForEach(item.elements) { order in
                            
                            HStack {
                                
                                VStack(alignment: .leading) {
                                    
                                    Text(order.id)
                                    
                                    HStack {
                                        Text("Date: ")
                                        Text(order.date, format: .dateTime)
                                    }
                                
                                    Text("Buyer: \(order.buyer)")
                                    
                                    Text("Items (lots): \(order.items) (\(order.lots))")
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text("Grand total: ")
                                        Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
                                    }
                                    
                                    HStack {
                                        Text("Shipping cost: ")
                                        
                                        var value = appController.shippingCost(forOrderWithId: order.id) ?? 0
                                        
                                        let shippingCostBinding = Binding<Float> {
                                            return value
                                        } set: { newValue in
                                            value = newValue
                                        }
                                        
                                        TextField("Shipping cost", value: shippingCostBinding,
                                                  format: .currency(code: "EUR").presentation(.isoCode)
                                        )
                                        .onSubmit {
                                            appController.updateShippingCost(forOrderWithId: order.id, cost: value)
                                        }
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    Text("Status: \(order.status.rawValue)")
                                    
                                    HStack {
                                        Text("Changed")
                                        Text(order.dateStatusChanged, format: .dateTime)
                                    }
                                    
                                    HStack {
                                        Text("Tracking no: ")
                                        if let no = appController.orderDetails(forOrderWithId: order.id)?.trackingNo {
                                            Text(no)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Drive thru: ")
                                        if let driveThruSent = appController.orderDetails(forOrderWithId: order.id)?.driveThruSent {
                                            Text("\(driveThruSent)")
                                        }
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text("Feedback Buyer:")
                                        if let ratingFromBuyer = appController.orderFeedbacks(forOrderWithId: order.id).buyerFeedback()?.rating {
                                            Text(ratingFromBuyer, format: .number)
                                        }
                                    }
                                    HStack {
                                        Text("Feedback Seller:")
                                        if let ratingFromSeller = appController.orderFeedbacks(forOrderWithId: order.id).sellerFeedback()?.rating {
                                            Text(ratingFromSeller, format: .number)
                                        }
                                    }
                                    
                                }
                                
                                VStack(alignment: .leading) {
                                    
                                    HStack {
                                        Text("Affranchissement: ")
                                        if let aff = appController.affranchissement(forOrderWithId: order.id) {
                                            Text(aff)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Transaction in: ")
                                        if let t = appController.incomeTransaction(forOrderWithId: order.id) {
                                            Text(t.createdAt, format: .dateTime)
                                        }
                                    }
                                    
                                    HStack {
                                        Text("Transaction out: ")
                                        if let t = appController.shippingTransaction(forOrderWithId: order.id) {
                                            Text(t.createdAt, format: .dateTime)
                                        }
                                    }
                                }
                                
                                Image(systemName: "chevron.right")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                            }
                            .padding()
                            .background(Color(nsColor: .quaternarySystemFill))
                            .border(Color(nsColor: .tertiarySystemFill))
                            .cornerRadius(6)
                            .onTapGesture {
                                
                                ordersActiveNavigationPath.append(order.id)
                            }
                            .padding([.leading, .trailing])
                        }
                        
                        Color.clear.frame(width: 0, height: 24)
                        
                    } header: {
                        
                        HStack {
                            Text(item.month).font(.title3)
                            Spacer()
                        }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(nsColor: .windowBackgroundColor).opacity(0.90))
                    }
                }
            }
        }
        .navigationTitle("Orders")
        .navigationDestination(for: OrderSummary.ID.self) { orderId in
            OrdersDetailView(orderId: orderId)
        }
        .toolbar {
            
            Button {
                Task {
                    await appController.reloadOrderSummaries()
                    await appController.refreshAllOrders()
                }
            } label: {
                Text("Refresh everything")
            }
        }
    }
}
