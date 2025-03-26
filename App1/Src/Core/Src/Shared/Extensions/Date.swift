
import Foundation



extension Date {
    
    
    public static var currentMonth: String {
        
        let cal = Calendar.current
        
        let comps = cal.dateComponents([.month, .year], from: Date())
        let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
        
        return month
    }
    
    
    public var firstDayOfMonth: Date {
        
        let calendar = Calendar.current
        
        guard calendar.component(.day, from: self) != 1 else { return self }
        
        var date = self
        date = calendar.date(bySetting: .day, value: 1, of: date)!
        date = calendar.date(byAdding: .month, value: -1, to: date)!
        
        return date
    }
    
    
    public var previousDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(byAdding: .day, value: -1, to: self)!
    }
    
    
    public var endOfDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: self)!
    }
    
    
    public var startOfDay: Date {
        
        let calendar = Calendar.current
        
        return calendar.date(bySettingHour: 0, minute: 0, second: 0, of: self)!
    }
    
    
    public func days(to date: Date) -> Int {
        
        let calendar = Calendar.current
        
        return calendar.dateComponents([.day], from: self, to: date).day!
    }
}
