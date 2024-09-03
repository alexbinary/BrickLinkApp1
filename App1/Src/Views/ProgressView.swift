
import SwiftUI



struct ProgressView: View {
    
    
    let targetValue: Float
    let value: Float
    
    
    let lineWidth: Double = 8
    
    
    var body: some View {
        
        VStack {
            
            GeometryReader { geo in
                
                let radius = min(geo.size.width, geo.size.height)/2
                let capSize = lineWidth
                
                ZStack {
                    
                    Circle()
                        .stroke(Color.accentColor, style: .init(lineWidth: lineWidth))
                        .shadow(radius: 2.0)
                        .opacity(0.2)
                    
                    let normalizedValue = value/targetValue
                    let angularValue = 2 * .pi * normalizedValue
                    
                    let startColor = Color.accentColor
                    let endColor = Color.green
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(normalizedValue))
                        .rotation(.radians(-.pi/2))
                        .stroke(
                            AngularGradient(
                                colors: [startColor, endColor],
                                center: .center,
                                startAngle: .radians(0 - .pi/2),
                                endAngle: .radians(Double(angularValue) - .pi/2)
                            ),
                            style: .init(lineWidth: lineWidth, lineCap: .round))
                    
                    Circle()
                        .size(width: capSize, height: capSize)
                        .offset(
                            x: geo.size.width/2 - capSize/2 + radius * cos(CGFloat(angularValue - .pi/2)),
                            y: geo.size.height/2 - capSize/2 + radius * sin(CGFloat(angularValue - .pi/2))
                        )
                        .fill(endColor)
                }
            }
        }
    }
}



extension Color {

    static var random: Color {

        let red = Double.random(in: 0...1)

        let green = Double.random(in: 0...1)

        let blue = Double.random(in: 0...1)

        return Color(red: red, green: green, blue: blue)

    }

}
