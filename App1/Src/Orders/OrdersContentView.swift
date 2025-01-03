
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
                            
                            OrderCardView(orderId: order.id, disclosureIndicatorVisible: true)
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
