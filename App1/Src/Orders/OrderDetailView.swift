
import SwiftUI
import HTMLEntities



struct PriceTableRow: Identifiable {
    
    var id: String { label }
    let label: String
    let cost: Float?
    let displayCost: Float?
}


struct OrderDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: OrderDetails
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HeaderTitleView(label: "􁊇 Address")
            
            Text(order.shippingAddressName)
            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
            Text(order.shippingAddressCountryCode)
            
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
            
            let statuses: [OrderStatus] = [.paid, .packed, .shipped, .completed]
            
            HStack {
                ForEach(statuses, id: \.self) { status in
                    Button {
                        Task {
                            await appController.updateOrderStatus(orderId: order.id, status: status)
                        }
                    } label: {
                        Text(status.rawValue)
                            .fontWeight(order.status == status ? .bold : .regular)
                    }
                }
            }
            
            Divider()
            
            HeaderTitleView(label: "􁊇 Items")
            
            Text("\(order.items) items in \(order.lots) lots - \(String(format: "%.0f", order.totalWeight))g")
            
            Table(appController.orderItems(forOrderWithId: order.id)) {
                
                TableColumn("Image") { item in
                    AsyncImage(url: appController.imageUrl(for: item))
                        .frame(minHeight: 60)
                }
                TableColumn("Condition", value: \.condition)
                TableColumn("Color") { item in
                    HStack {
                        appController.color(for: item).frame(width: 18, height: 18)
                        Text(appController.colorName(for: item))
                    }
                }
                TableColumn("Name") { item in
                    Text(item.name.htmlUnescape()).lineLimit(nil)
                }
                TableColumn("Ref", value: \.ref)
                TableColumn("Comment", value: \.comment)
                TableColumn("Quantity", value: \.quantity)
                TableColumn("Left", value: \.quantityLeft)
                TableColumn("PU") { item in
                    
                    if item.unitPriceFinal != item.unitPrice {
                        
                        Text(item.unitPrice, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                            .strikethrough()
                    }
                    Text(item.unitPriceFinal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                }
            }
            .frame(minHeight: 400)
            
            Divider()
        }
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
