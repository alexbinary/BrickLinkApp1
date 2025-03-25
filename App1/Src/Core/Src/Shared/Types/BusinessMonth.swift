
import Foundation



public struct BusinessMonth: Hashable {
    
    
    public let year: Int
    public let monthOfYear: Int
    
    
    public init(fromYear year: Int, month: Int) throws {
        
        let comp = DateComponents(year: year, month: month)
        
        guard let date = Calendar.current.date(from: comp),
              Calendar.current.dateComponents([.year, .month], from: date) == comp
        else {
            throw "invalid values"
        }
        
        self.year = year
        self.monthOfYear = month
    }
    
    
    public var yyyymm: String {
        
        let m = monthOfYear
        let mf = "\(m)".count == 1 ? "0\(m)" : "\(m)"
        
        return "\(year)-\(mf)"
    }
    
    
    public var name: String {
        
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: self.year, month: self.monthOfYear))!
        
        let comps = calendar.dateComponents([.month, .year], from: date)
        
        return "\(calendar.monthSymbols[comps.month!-1]) \(comps.year!)"
    }
    
    
    public func offset(by n: Int) -> BusinessMonth {
        
        let calendar = Calendar.current
        let dateCurrent = calendar.date(from: DateComponents(year: self.year, month: self.monthOfYear))!
        
        let dateNext = calendar.date(
            byAdding: .month, value: n,
            to: dateCurrent
        )!
        
        return dateNext.businessMonth
    }
    
    
    public var nextMonth: BusinessMonth {
        
        self.offset(by: +1)
    }
}



extension BusinessMonth: Identifiable {
    
    
    public var id: String { yyyymm }
}



extension Date {
    
    
    public var businessMonth: BusinessMonth {
        
        let calendar = Calendar.current
        
        return try! BusinessMonth(
            fromYear: calendar.component(.year, from: self),
            month: calendar.component(.month, from: self)
        )
    }
}



extension BusinessMonth: Comparable {
    
    
    public static func < (lhs: BusinessMonth, rhs: BusinessMonth) -> Bool {
        
        lhs.yyyymm < rhs.yyyymm
    }
}



extension BusinessMonth {
    
    
    public static var current: BusinessMonth {
        
        Date().businessMonth
    }
    
    
    
    public static var firstOfYear: BusinessMonth {
        
        let calendar = Calendar.current
        
        let date = calendar.date(from: DateComponents(
            year: current.year, month: 1, day: 1,
            hour: 0, minute: 0, second: 0
        ))!
        
        return date.businessMonth
    }
    
    
    
    public static func allMonths(
        
        from monthStart: BusinessMonth,
        to monthEnd: BusinessMonth
    
    ) -> [BusinessMonth] {
        
        var months: [BusinessMonth] = []
        
        var month = monthStart
        while (month <= monthEnd) {
            
            months.append(month)
            month = month.nextMonth
        }
        
        return months
    }
}
