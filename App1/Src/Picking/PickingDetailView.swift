
import SwiftUI



struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<Order.ID>
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderIds.isEmpty {
                    
                    Text("select an order")
                    
                } else if orderItems.isEmpty {
                    
                    Text("loading order...")
                    
                } else {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        PickingItemsView(selectedOrderIds: selectedOrderIds, orderItems: orderItems)
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Packing")
                        
                        if selectedOrderIds.count != 1 {
                            
                            Text("select only one order")
                            
                        } else if let order = order {
                            
                            Text("Address").font(.title2)
                            
                            Text(order.shippingAddressName ?? "")
                            Text(order.shippingAddress ?? "").fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode ?? "")
                            
                            Text("Shipping price").font(.title2)
                            
                            HStack {
                                Text(order.shippingCost!, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                Text(" - \(order.shippingMethodName!) \(String(format: "%.0f", order.totalWeight!))g")
                            }
                            
                            ShippingCostView(order: order)
                            
                            Text("Affranchissement").font(.title2)
                            
                            
                        }
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await loadOrder()
                await loadOrderItems()
            }
            .onChange(of: selectedOrderIds) { oldValue, newValue in
                Task {
                    await loadOrder()
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        self.order = nil
        
        if selectedOrderIds.count == 1 {
            self.order = await appController.getOrder(orderId: selectedOrderIds.first!)
        }
    }
    
    
    func loadOrderItems() async {
        
        self.orderItems.removeAll()
        
        for orderId in selectedOrderIds {
            self.orderItems.append(contentsOf: await appController.getOrderItems(orderId: orderId))
        }
    }
}
