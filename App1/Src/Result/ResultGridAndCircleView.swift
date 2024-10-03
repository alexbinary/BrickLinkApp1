
import SwiftUI
import Charts



struct ResultGridAndCircleView: View {
    
    
    let title: String
    let subtitle: String
    
    let totalItems: Float
    let totalShipping: Float
    let totalItemCost: Float
    let totalShippingCost: Float
    let totalFees: Float
    let totalResult: Float
    let profitMargin: Float
    
    let circleViewVisible: Bool
    
    @State var animateCircles = false
    
    
    var body: some View {
        
        VStack(spacing: 24) {
            
            VStack {
                Text(subtitle).font(.title3)
                Text(title).font(.title)
            }
            
            HStack(spacing: 48) {
                
                Grid(alignment: .leading) {
                    
                    GridRow {
                        
                        Text("Total items")
                        
                        Text(
                            abs(totalItems),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(.income)
                    }
                    
                    GridRow {
                        
                        Text("Total shipping")
                        
                        Text(
                            abs(totalShipping),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(.income)
                    }
                    
                    Color.clear.frame(width: 0, height: 8)
                    
                    GridRow {
                        
                        Text("Total item cost")
                        
                        Text(
                            abs(totalItemCost),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(.expense)
                    }
                    
                    GridRow {
                        
                        Text("Total shipping cost")
                        
                        Text(
                            abs(totalShippingCost),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(.expense)
                    }
                    
                    GridRow {
                        
                        Text("Total fees")
                        
                        Text(
                            abs(totalFees),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(.expense)
                    }
                    
                    Color.clear.frame(width: 0, height: 8)
                    
                    GridRow {
                        
                        Text("Total result")
                        
                        Text(
                            abs(totalResult),
                            format: .currency(code: "EUR").presentation(.isoCode)
                        )
                        .signedAmountColor(totalResult)
                    }
                    .font(.title)
                }
                .font(.title2)
                
                let innerCircleSize: CGFloat = 100
                let outerCircleSize: CGFloat = 140
                
                ResultCircleView(
                    totalItems: totalItems,
                    totalShipping: totalShipping,
                    totalItemCost: totalItemCost,
                    totalShippingCost: totalShippingCost,
                    totalFees: totalFees,
                    profitMargin: profitMargin,
                    innerCircleSize: innerCircleSize,
                    outerCircleSize: outerCircleSize
                )
                .opacity(circleViewVisible ? 1 : 0)
                .frame(width: circleViewVisible ? outerCircleSize : 0, height: outerCircleSize)
            }
        }
    }
}
