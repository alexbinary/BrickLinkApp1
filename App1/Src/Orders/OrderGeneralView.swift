
import SwiftUI
import HTMLEntities



struct OrderGeneralView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: OrderDetails
    
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 96) {
                
                VStack(alignment: .leading) {
                    
                    Text("􂙡 Address")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(order.shippingAddressName)
                    Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
                    Text(order.shippingAddressCountryCode)
                }
                .font(.title3)
                
                HStack(spacing: 48) {
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("􀖧 Subtotal")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(order.subTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .font(.title3)
                            
                            if order.dispCostCurrencyCode != order.costCurrencyCode {
                                Text(order.dispSubTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            
                            Text("􀖧 Shipping")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                .font(.title3)
                            
                            if order.dispCostCurrencyCode != order.costCurrencyCode {
                                Text(order.dispShippingCost, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                    .font(.title3)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        
                        Text("􀖧 Grand total")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(order.grandTotal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                            .font(.title2)
                        
                        if order.dispCostCurrencyCode != order.costCurrencyCode {
                            Text(order.dispGrandTotal, format: .currency(code: order.dispCostCurrencyCode).presentation(.isoCode))
                                .font(.title2)
                        }
                    }
                }
            }
            
            Divider()
            
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
                TableColumn("PU") { item in
                    
                    if item.unitPriceFinal != item.unitPrice {
                        
                        Text(item.unitPrice, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                            .strikethrough()
                    }
                    Text(item.unitPriceFinal, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                }
            }
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
