
import SwiftUI
import Core



struct OrderDetailShippingView: View {
    
    
    @Environment(OrderStore.self)
    var orderStore
    
    @Environment(ShippingStore.self)
    var shippingStore
    
    
    let order: Order
    var orderDetails: OrderDetails { orderStore.orderDetails(for: order)! }
    
    init(_ order: Order) {
        self.order = order
    }
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
                
            HStack(alignment: .top, spacing: 12) {
                
                VStack(alignment: .leading, spacing: 12) {
                    HeaderTitleView(label: "􂙡 Address")
                    OrderAddressView(order).font(.title3).padding(.horizontal)
                }
                .padding(8)
                .frame(maxHeight: .infinity, alignment: .top)
                .roundedContainer(style: .outline)
                
                Spacer()
                
                let width1: CGFloat = 90
                let width2: CGFloat = 170
                let height1: CGFloat = 20
                let height2: CGFloat = 10
                
                Grid(alignment: .leading) {
                    
                    GridRow {
                        
                        InfoCardView(title: "􀭭 Weight") {
                            
                            Text("\(String(format: "%.0f", orderDetails.totalWeight))g")
                                .bold()
                                .frame(width: width1, height: height1)
                            
                        } detail: {
                            
                            Text("Charged \(String(format: "%.0f", orderDetails.totalWeight * orderWeightMarginRatio))g")
                                .foregroundStyle(.secondary)
                                .frame(width: width1, height: height2)
                        }
                        
                        InfoCardView(title: "􀖧 Shipping") {
                            
                            Text(orderDetails.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .bold()
                                .frame(width: width2, height: height1)
                            
                        } detail: {
                            
                            Text(orderDetails.shippingMethodName ?? "")
                                .lineLimit(2, reservesSpace: true)
                                .foregroundStyle(.secondary)
                                .frame(height: height2)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                
                        HeaderTitleView(label: "􂄹 Remarks")
                        
                        Text(orderDetails.remarks ?? "").font(.title3).padding(.horizontal)
                    }
                    .padding(8)
                    .roundedContainer(style: .outline)
                }
                
                Spacer()
                
                ShippingCostInfo(
                    shippingMethodId: orderDetails.shippingMethodId,
                    selectedShippingCost: selectedShippingCost
                )
                .padding()
                .frame(maxHeight: .infinity, alignment: .top)
                .roundedContainer(style: .info)
            }
            
            Divider()
            
            HStack(alignment: .top, spacing: 48) {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􀐚 Packing & Stamping")
                    
                    let recommendedStampingMethod = shippingStore.recommendedStampingMethod(for: order)
                    
                    Grid(alignment: .leading, verticalSpacing: 8) {
                        
                        GridRow {
                            Text("Shipping cost :")
                            
                            var shippingCostEditValue = shippingStore.confirmedShippingCost(for: order) ?? 0
                            
                            let shippingCostBinding = Binding<Float> {
                                return shippingCostEditValue
                            } set: { newValue in
                                shippingCostEditValue = newValue
                            }
                            
                            TextField(
                                "Shipping cost", value: shippingCostBinding,
                                format: .currency(code: "EUR").presentation(.isoCode)
                            )
                            .onSubmit {
                                shippingStore.confirmShippingCost(for: order, cost: shippingCostEditValue)
                            }
                            .frame(maxWidth: 120)
                            
                            HStack {
                                Button("Save") {
                                    shippingStore.confirmShippingCost(for: order, cost: shippingCostEditValue)
                                }
                                
                                if let shippingCostPredictedValue = selectedShippingCost?.value {
                                    
                                    Button {
                                        shippingStore.confirmShippingCost(for: order, cost: NSDecimalNumber(decimal:  shippingCostPredictedValue).floatValue)
                                    } label: {
                                        HStack {
                                            Text("Predicted:")
                                            Text(shippingCostPredictedValue, format: .currency(code: "EUR").presentation(.isoCode))
                                        }
                                    }
                                }
                            }
                        }
                        
                        GridRow {
                            Text("Stamping :")
                            
                            if let confirmedMethod = shippingStore.confirmedStamping(for: order) {
                                Text(confirmedMethod)
                            } else {
                                Text("")
                            }
                            
                            HStack {
                                Button("Recommended: \(recommendedStampingMethod)") {
                                    shippingStore.confirmStamping(for: order, stamping: recommendedStampingMethod)
                                }
                                
                                if recommendedStampingMethod != "Bureau de poste" {
                                    Button("Bureau de poste") {
                                        shippingStore.confirmStamping(for: order, stamping: "Bureau de poste")
                                    }
                                }
                            }
                        }
                        
                        GridRow {
                            Text("")
                            Text("")
                            HStack {
                                Button("Validate without stamping") {
                                    shippingStore.validateOrderWithoutStamping(order)
                                }
                                if let date = shippingStore.dateOrderValidatedWithoutStamping(order) {
                                    Text("Validated without stamping on")
                                    Text(date, format: .dateTime)
                                }
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􁁾 Shipping")
                    
                    Grid(alignment: .leading, verticalSpacing: 8) {
                        
                        GridRow {
                            
                            Text("Tracking no :")
                            
                            var trackingNoEditValue = orderDetails.trackingNo
                            
                            let trackingNoBinding = Binding<String> {
                                return trackingNoEditValue ?? ""
                            } set: { newValue in
                                trackingNoEditValue = newValue
                            }
                            
                            TextField("Tracking No", text: trackingNoBinding)
                                .onSubmit {
                                    Task { await orderStore.updateTrackingNo(for: order, trackingNo: trackingNoEditValue ?? "") }
                                }
                                .frame(maxWidth: 140)
                            
                            Button("Save") {
                                Task { await orderStore.updateTrackingNo(for: order, trackingNo: trackingNoEditValue ?? "") }
                            }
                        }
                        
                        GridRow {
                            
                            Text("Drive thru :")
                            
                            if orderDetails.driveThruSent {
                                Text("sent")
                            } else {
                                Text("not sent")
                            }
                            
                            Button("Send") {
                                Task { await orderStore.sendDriveThru(for: order) }
                            }
                        }
                        
                        Button("Ship and send Drive thru") {
                            Task {
                                await orderStore.updateOrderStatus(order, status: .shipped)
                                await orderStore.sendDriveThru(for: order)
                            }
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    
    var selectedShippingCost: SelectedShippingCost? {
        
        shippingStore.selectedShippingCost(for: order)
    }
}



#Preview {
    
    let env = createEnv()
    let order = env.stores.order.orders.first!
    
    OrderDetailShippingView(order)
        .inject(env)
}
