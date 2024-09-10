
import Foundation
import SwiftUI



extension String: Error { }



extension Array where Element: Equatable {


    var stableUniqueByFirstOccurence: Self {
        
        var uniqueItems: Self = []
        
        for item in self {
            if !uniqueItems.contains(item) {
                uniqueItems.append(item)
            }
        }
        
        return uniqueItems
    }
}



extension Date {
    
    
    static var currentMonth: String {
        
        let cal = Calendar.current
        
        let comps = cal.dateComponents([.month, .year], from: Date())
        let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
        
        return month
    }
    
    
    var firstDayOfMonth: Date {
        
        let calendar = Calendar.current
        
        guard calendar.component(.day, from: self) != 1 else { return self }
        
        var date = self
        date = calendar.date(bySetting: .day, value: 1, of: date)!
        date = calendar.date(byAdding: .month, value: -1, to: date)!
        
        return date
    }
    
    
    var previousDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .day, value: -1, to: self)!
    }
    
    
    var endOfDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    
    var startOfDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
}



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
}
