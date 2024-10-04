
import SwiftUI


struct OrdersContentView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    @Binding var selectedOrderId: OrderSummary.ID?
    
    
    var body: some View {
        
        Table(of: OrderSummary.self, selection: $selectedOrderId) {
            
            Group {
                
                TableColumn("ID", value: \OrderSummary.id)
                
                TableColumn("Date") { (order: OrderSummary) in
                    Text(order.date, format: .dateTime)
                }
                
                TableColumn("Buyer", value: \OrderSummary.buyer)
                
                TableColumn("Items (lots)") { (order: OrderSummary) in
                    Text(verbatim: "\(order.items) (\(order.lots))")
                }
                
                TableColumn("Grand total") { (order: OrderSummary) in
                    Text(order.grandTotal, format: .currency(code: "EUR").presentation(.isoCode))
                }
                
                TableColumn("Shipping cost") { (order: OrderSummary) in
                    
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
                
                TableColumn("Status", value: \OrderSummary.status)
                
                TableColumn("Changed") { (order: OrderSummary) in
                    Text(order.dateStatusChanged, format: .dateTime)
                }
                
                TableColumn("Tracking no") { (order: OrderSummary) in
                    if let no = appController.orderDetails(forOrderWithId: order.id)?.trackingNo {
                        Text(no)
                    }
                }
                
                TableColumn("Drive thru") { (order: OrderSummary) in
                    if let driveThruSent = appController.orderDetails(forOrderWithId: order.id)?.driveThruSent {
                        Text("\(driveThruSent)")
                    }
                }
            }
            Group {
                
                TableColumn("Feedback") { (order: OrderSummary) in
                    HStack {
                        Text("Buyer:")
                        if let ratingFromBuyer = appController.orderFeedbacks(forOrderWithId: order.id).first(where: { $0.ratingOfBs == "S" })?.rating {
                            Text(ratingFromBuyer, format: .number)
                        }
                    }
                    HStack {
                        Text("Me:")
                        if let ratingFromSeller = appController.orderFeedbacks(forOrderWithId: order.id).first(where: { $0.ratingOfBs == "B" })?.rating {
                            Text(ratingFromSeller, format: .number)
                        }
                    }
                }

                TableColumn("Affranchissement") { (order: OrderSummary) in
                    if let aff = appController.affranchissement(forOrderWithId: order.id) {
                        Text(aff)
                    }
                }
                
                TableColumn("Transaction in") { (order: OrderSummary) in
                    if let t = appController.incomeTransaction(forOrderWithId: order.id) {
                        Text(t.createdAt, format: .dateTime)
                    }
                }
                
                TableColumn("Transaction out") { (order: OrderSummary) in
                    if let t = appController.shippingTransaction(forOrderWithId: order.id) {
                        Text(t.createdAt, format: .dateTime)
                    }
                }
            }
            
        } rows: {
            
            ForEach(appController.orderSummaries.grouppedByMonth, id: \.month) { item in
                
                Section(item.month) {
                    
                    ForEach(item.elements) { TableRow($0) }
                }
            }
        }
        .navigationTitle("Orders")
        .toolbar {
            
            Button {
                Task {
                    await appController.refresh()
                }
            } label: {
                Text("Refresh everything")
            }
        }
    }
}
