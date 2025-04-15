
import SwiftUI



extension Color {
    
    
    public init(fromBLCode code: String) {
        
        let r, g, b: CGFloat

        let scanner = Scanner(string: code)
        var hexNumber: UInt64 = 0

        scanner.scanHexInt64(&hexNumber)
            
        r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
        g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
        b = CGFloat((hexNumber & 0x0000ff)) / 255

        self.init(NSColor(red: r, green: g, blue: b, alpha: 1))
    }
    
    
    static let windowBackgroundColor = Color(nsColor: .windowBackgroundColor)
    static let secondarySystemFill = Color(nsColor: .secondarySystemFill)
    static let tertiarySystemFill = Color(nsColor: .tertiarySystemFill)
    static let quaternarySystemFill = Color(nsColor: .quaternarySystemFill)
}