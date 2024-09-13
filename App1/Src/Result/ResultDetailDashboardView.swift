
import SwiftUI
import Charts



struct ResultDetailDashboardView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let orders: [OrderDetails]
    let title: String
    
    
    var body: some View {
        
        let totalItems = orders.reduce(0) { $0 + $1.subTotal }
        let totalShipping = orders.reduce(0) { $0 + $1.shippingCost }
        
        let totalItemCost: Float = 0
        let totalShippingCost = orders.reduce(0) { $0 + (appController.shippingCost(forOrderWithId: $1.id) ?? 0) }
        
        let totalFees = orders.reduce(0) { (total: Float, order) in
            
            var fees: Float = 0
            
            if let income = appController.transactions.first(where: { $0.type == .orderIncome && $0.orderRefIn == order.id })?.amount {
            
                fees = order.grandTotal - income
            }
            
            return total + fees
        }
        
        let totalResult = totalItems + totalShipping - totalItemCost - totalShippingCost - totalFees
        
        VStack(spacing: 48) {
            
            Text(title).font(.title)
            
            Grid(alignment: .leading) {
                
                GridRow {
                    Text("Total items")
                    Text(totalItems, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.income)
                }
                .font(.title2)
                
                GridRow {
                    Text("Total shipping")
                    Text(totalShipping, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.income)
                }
                .font(.title2)
                
                Color.clear.frame(height: 16)
                
                GridRow {
                    Text("Total item cost")
                    Text(totalItemCost, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.expense)
                }
                .font(.title2)
                
                GridRow {
                    Text("Total shipping cost")
                    Text(totalShippingCost, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.expense)
                }
                .font(.title2)
                
                GridRow {
                    Text("Total fees")
                    Text(totalFees, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(.expense)
                }
                .font(.title2)
                
                Color.clear.frame(height: 24)
                
                GridRow {
                    Text("Total result")
                    Text(totalResult, format: .currency(code: "EUR").presentation(.isoCode)).signedAmountColor(totalResult)
                }
                .font(.title)
            }
        }
    }
}
