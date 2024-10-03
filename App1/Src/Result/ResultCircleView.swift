
import SwiftUI
import Charts



struct ResultCircleView: View {
    
    
    let totalItems: Float
    let totalShipping: Float
    let totalItemCost: Float
    let totalShippingCost: Float
    let totalFees: Float
    let profitMargin: Float
    
    let innerCircleSize: CGFloat
    let outerCircleSize: CGFloat
    
    @State var animateCircles = false
    
    
    var body: some View {
        
        let ratios: (income: CGFloat, expense: CGFloat) = {
            
            let income = CGFloat(abs(totalItems + totalShipping))
            let expense = CGFloat(abs(totalItemCost + totalShippingCost + totalFees))
            
            if income > expense {
                return (income: 1.0, expense: expense/income)
            } else {
                return (income: income/expense, expense: 1.0)
            }
        }()
        
        ZStack(alignment: .center) {
            
            Circle()
                .trim(from: 0, to: 0.95)
                .rotation(.radians(-3 * .pi/4))
                .stroke(red.opacity(0.1), style: .init(lineWidth: 4, lineCap: .round))
                .frame(width: innerCircleSize, height: innerCircleSize)
            
            Circle()
                .trim(from: 0, to: 0.95)
                .rotation(.radians(-3 * .pi/4))
                .stroke(green.opacity(0.1), style: .init(lineWidth: 4, lineCap: .round))
                .frame(width: outerCircleSize, height: outerCircleSize)
            
            Circle()
                .trim(from: 0, to: 0.95 * ratios.expense)
                .rotation(.radians(-3 * .pi/4))
                .stroke(red, style: .init(lineWidth: 6, lineCap: .round))
                .frame(width: innerCircleSize, height: innerCircleSize)
            
            Circle()
                .trim(from: 0, to: 0.95 * ratios.income)
                .rotation(.radians(-3 * .pi/4))
                .stroke(green, style: .init(lineWidth: 6, lineCap: .round))
                .frame(width: outerCircleSize, height: outerCircleSize)
            
            VStack {
                Text("Profit margin")
                Text(profitMargin, format: .percent.precision(.fractionLength(0))).font(.title)
                    .signedAmountColor(profitMargin)
            }
        }
        .animation(.easeOut(duration: 0.2), value: animateCircles ? [ratios.income, ratios.expense] : nil)
        .onAppear {
            DispatchQueue.main.async {
                self.animateCircles = true
            }
        }
    }
}
