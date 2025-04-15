
import SwiftUI



struct ResultCircleView: View {
    
    
    let income: Float
    let expense: Float
    let profitMargin: Float
    
    let innerCircleSize: CGFloat
    let outerCircleSize: CGFloat
    
    
    let lineWidthTrack: CGFloat = 4
    let lineWidthValue: CGFloat = 6
    let circleBaseTrim: CGFloat = 0.95
    let circleRotation: Angle = .radians(-3 * .pi/4)
    
    @State var animateCircles = false
    
    
    var body: some View {
        
        let ratios: (income: Percent, expense: Percent) = {
            
            let income = Double(income)
            let expense = Double(expense)
            
            if income == 0 || expense == 0 {
                return (income: 0%, expense: 0%)
            }
            
            if income > expense {
                return (income: 100%, expense: Percent(expense/income))
            } else {
                return (income: Percent(income/expense), expense: 100%)
            }
        }()
        
        ZStack(alignment: .center) {
            
            circle(size: outerCircleSize, lineWidth: lineWidthTrack, value: 100%, color: green.opacity(0.1))
            circle(size: outerCircleSize, lineWidth: lineWidthValue, value: ratios.income, color: green)
            
            circle(size: innerCircleSize, lineWidth: lineWidthTrack, value: 100%, color: red.opacity(0.1))
            circle(size: innerCircleSize, lineWidth: lineWidthValue, value: ratios.expense, color: red)
            
            if !profitMargin.isNaN {
                VStack {
                    Text("Profit margin")    
                    Text(profitMargin, format: .percent.precision(.fractionLength(0))).font(.title)
                        .amountColor(.goodIfPositive(profitMargin, zero: .neutral))
                }
            }
        }
        .animation(.easeOut(duration: 0.2), value: animateCircles ? [ratios.income, ratios.expense] : nil)
        .onAppear { DispatchQueue.main.async {
            self.animateCircles = true
        }}
    }
    
    
    @ViewBuilder
    func circle(size: CGFloat, lineWidth: CGFloat, value: Percent, color: Color) -> some View {
        
        Circle()
            .trim(from: 0, to: circleBaseTrim * value)
            .rotation(circleRotation)
            .stroke(color, style: .init(lineWidth: lineWidth, lineCap: .round))
            .frame(width: size, height: size)
        
    }
}
