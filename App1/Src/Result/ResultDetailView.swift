
import SwiftUI
import Charts



struct ResultDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderDetails.ID>
    
    
    var body: some View {
        
        let orderIds = selectedOrderIds.isEmpty ? appController.orderSummaries.map { $0.id } : [OrderSummary.ID](selectedOrderIds)
        
        let orders = orderIds.compactMap {
            appController.orderDetails(forOrderWithId: $0)
        }
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
        
        let totalItemCost: Float = 0
        let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
        
        let totalResult = totalItems + totalShipping + totalItemCost + totalShippingCost
        
        Grid {
            GridRow {
                Text("Total items")
                Text(totalItems, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.income)
            }
            GridRow {
                Text("Total shipping")
                Text(totalShipping, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.income)
            }
            GridRow {
                Text("Total item cost")
                Text(totalItemCost, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.expense)
            }
            GridRow {
                Text("Total shipping cost")
                Text(totalShippingCost, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.expense)
            }
            Divider()
            GridRow {
                Text("Total result")
                Text(totalResult, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(totalResult)
            }
        }
    }
}
