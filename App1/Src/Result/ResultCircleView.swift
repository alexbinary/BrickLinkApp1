
import SwiftUI
import Charts



struct ResultCircleView: View {
    
    
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
                .opacity(circleViewVisible ? 1 : 0)
                .frame(width: circleViewVisible ? outerCircleSize : 0, height: outerCircleSize)
                .animation(.easeOut(duration: 0.2), value: animateCircles ? [ratios.income, ratios.expense] : nil)
                .onAppear {
                    DispatchQueue.main.async {
                        self.animateCircles = true
                    }
                }
            }
        }
    }
}
