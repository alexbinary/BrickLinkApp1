
import SwiftUI



struct PriceTableRow: Identifiable {
    
    var id: String { label }
    let label: String
    let cost: Float?
    let displayCost: Float?
}


struct OrdersDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderId: Order.ID?
    
    @State var order: Order? = nil
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderId == nil {
                    
                    Text("select an order")
                    
                } else if order == nil {
                    
                    Text("loading order...")
                    
                } else if let order = order {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        HeaderTitleView(label: "􁊇 Address")
                        
                        Text(order.shippingAddressName ?? "")
                        Text(order.shippingAddress ?? "").fixedSize(horizontal: false, vertical: true)
                        Text(order.shippingAddressCountryCode ?? "")
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Cost")
                        
                        Table(of: PriceTableRow.self) {
                            TableColumn("") { row in
                                Text(row.label).fontWeight(.bold)
                            }
                            TableColumn("Cost") { row in
                                if let cost = row.cost {
                                    Text(cost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                }
                            }
                            if order.dispCostCurrencyCode != order.costCurrencyCode {
                                TableColumn("Display") { row in
                                    if let cost = row.displayCost {
                                        Text(cost, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                    }
                                }
                            }
                        } rows: {
                            TableRow(PriceTableRow(
                                label: "Subtotal",
                                cost: order.subTotal,
                                displayCost: order.dispSubTotal
                            ))
                            TableRow(PriceTableRow(
                                label: "Shipping",
                                cost: order.shippingCost,
                                displayCost: order.dispShippingCost
                            ))
                            TableRow(PriceTableRow(
                                label: "Grand total",
                                cost: order.grandTotal,
                                displayCost: order.dispGrandTotal
                            ))
                        }
                        .tableColumnHeaders(.hidden)
                        .frame(minHeight: 100)
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Update status")
                        
                        let statuses = ["PAID", "PACKED", "SHIPPED", "COMPLETED"]
                        
                        HStack {
                            ForEach(statuses, id: \.self) { status in
                                Button {
                                    Task {
                                        await appController.updateOrderStatus(orderId: order.id, status: status)
                                        await loadOrder()
                                    }
                                } label: {
                                    Text(status)
                                        .fontWeight(order.status == status ? .bold : .regular)
                                }
                            }
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Tracking")
                        
                        if order.trackingNo?.isEmpty ?? true {
                            Text("Tracking no not set")
                        } else {
                            Text("Tracking no set")
                        }
                        
                        var trackingNoEditValue = order.trackingNo
                        
                        let trackingNoBinding = Binding<String> {
                            return trackingNoEditValue ?? ""
                        } set: { newValue in
                            trackingNoEditValue = newValue
                        }
                        
                        TextField("Tracking No", text: trackingNoBinding)
                            .onSubmit {
                                Task {
                                    await appController.updateTrackingNo(forOrderWithId: order.id, trackingNo: trackingNoEditValue ?? "")
                                    await loadOrder()
                                }
                            }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Drive thru")
                        
                        if order.driveThruSent {
                            Text("Drive through sent")
                        } else {
                            Text("Drive through not sent")
                        }
                        
                        Button {
                            Task {
                                await appController.sendDriveThru(orderId: order.id)
                                await loadOrder()
                            }
                        } label: {
                            Text("Send drive thru")
                        }
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Items")
                        
                        Text("\(order.items) items in \(order.lots) lots - \(String(format: "%.0f", order.totalWeight!))g")
                        
                        Table(orderItems) {
                            
                            TableColumn("Condition", value: \.condition)
                            TableColumn("Color", value: \.color)
                            TableColumn("Ref", value: \.ref)
                            TableColumn("Name", value: \.name)
                            TableColumn("Comment", value: \.comment)
                            TableColumn("Location", value: \.location)
                            TableColumn("Quantity", value: \.quantity)
                            TableColumn("Left", value: \.quantityLeft)
                        }
                        .frame(minHeight: 400)
                        
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
            .onChange(of: selectedOrderId) { oldValue, newValue in
                Task {
                    await loadOrder()
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.order = nil
        self.order = await appController.getOrder(orderId: orderId)
    }
    
    
    func loadOrderItems() async {
        
        guard let orderId = selectedOrderId else { return }
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: orderId)
    }
}
