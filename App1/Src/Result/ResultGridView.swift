
import SwiftUI
import Charts



struct ResultGridView: View {
    

    let totalItems: Float
    let totalShipping: Float
    let totalItemCost: Float
    let totalShippingCost: Float
    let totalFees: Float
    let totalRefund: Float
    let totalResult: Float
    
    
    var body: some View {
        
        Grid(alignment: .leading) {
            
            GridRow {
                
                Text("Total items")
                
                Text(
                    abs(totalItems),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.income)
            }
            
            GridRow {
                
                Text("Total shipping")
                
                Text(
                    abs(totalShipping),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.income)
            }
            
            Color.clear.frame(width: 0, height: 8)
            
            GridRow {
                
                Text("Total item cost")
                
                Text(
                    abs(totalItemCost),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.expense)
            }
            
            GridRow {
                
                Text("Total shipping cost")
                
                Text(
                    abs(totalShippingCost),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.expense)
            }
            
            Color.clear.frame(width: 0, height: 8)
            
            GridRow {
                
                Text("Total fees")
                
                Text(
                    abs(totalFees),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.expense)
            }
            
            GridRow {
                
                Text("Total refunds")
                
                Text(
                    abs(totalRefund),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(.expense)
            }
            
            Color.clear.frame(width: 0, height: 8)
            
            GridRow {
                
                Text("Total result")
                
                Text(
                    abs(totalResult),
                    format: .currency(code: "EUR").presentation(.isoCode)
                )
                .amountColor(totalResult)
            }
            .font(.title)
        }
        .font(.title2)
    }
}
