
import SwiftUI



struct PriceTableRow: Identifiable {
    
    var id: String { label }
    let label: String
    let cost: Float?
    let displayCost: Float?
}


struct OrdersDetailDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: Order
    let reloadOrder: ()->()
    
    @State var orderItems: [OrderItem] = []
    @State var orderFeedbacks: [Feedback] = []
    
    
    var body: some View {
        
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
                            reloadOrder()
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
                        reloadOrder()
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
                    reloadOrder()
                }
            } label: {
                Text("Send drive thru")
            }
            
            Divider()
            
            HeaderTitleView(label: "􁊇 Feedback")
            
            Table(orderFeedbacks.sorted { $0.dateRated < $1.dateRated }) {
                TableColumn("From", value: \.from)
                TableColumn("Rating") { feedback in
                    Text("\(feedback.rating)")
                }
                TableColumn("Comment", value: \.comment)
                TableColumn("Date") { feedback in
                    Text(feedback.dateRated, format: .dateTime)
                }
            }
            .frame(minHeight: 100)
            
            Button {
                Task {
                    await appController.postOrderFeedback(
                        orderId: order.id, rating: 0,
                        comment: order.shippingAddressCountryCode == "FR" ? "Merci pour votre commande !" : "Thanks for your order!"
                    )
                    await loadOrderFeedbacks()
                }
            } label: {
                Text("Post Praise feedback")
            }
            
            Divider()
            
            HeaderTitleView(label: "􁊇 Items")
            
            Text("\(order.items) items in \(order.lots) lots - \(String(format: "%.0f", order.totalWeight!))g")
            
            Table(orderItems) {
                
                TableColumn("Condition", value: \.condition)
                TableColumn("Color") { value in
                    HStack {
                        appController.color(id: value.colorId).frame(width: 18, height: 18)
                        Text(appController.colorName(id: value.colorId))
                    }
                }
                TableColumn("Name", value: \.name)
                TableColumn("Ref", value: \.ref)
                TableColumn("Comment", value: \.comment)
                TableColumn("Quantity", value: \.quantity)
                TableColumn("Left", value: \.quantityLeft)
            }
            .frame(minHeight: 400)
            
            Divider()
        }
        .task {
            await loadOrderItems()
            await loadOrderFeedbacks()
        }
    }
    
    
    func loadOrderItems() async {
        
        self.orderItems.removeAll()
        self.orderItems = await appController.getOrderItems(orderId: order.id)
    }
    
    
    func loadOrderFeedbacks() async {
        
        self.orderFeedbacks.removeAll()
        self.orderFeedbacks = await appController.getOrderFeedbacks(orderId: order.id)
    }
}
