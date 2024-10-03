
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
                
                ResultGridView(
                    totalItems: totalItems,
                    totalShipping: totalShipping,
                    totalItemCost: totalItemCost,
                    totalShippingCost: totalShippingCost,
                    totalFees: totalFees,
                    totalResult: totalResult
                )
                
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
