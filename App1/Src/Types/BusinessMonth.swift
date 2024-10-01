
import Foundation



struct BusinessMonth: Hashable {
    
    
    let year: Int
    let monthOfYear: Int
    
    
    init(fromYear year: Int, month: Int) throws {
        
        let comp = DateComponents(year: year, month: month)
        
        guard let date = Calendar.current.date(from: comp),
              Calendar.current.dateComponents([.year, .month], from: date) == comp
        else {
            throw "invalid values"
        }
        
        self.year = year
        self.monthOfYear = month
    }
    
    
    var name: String {
        
        let calendar = Calendar.current
        let date = calendar.date(from: DateComponents(year: self.year, month: self.monthOfYear))!
        
        let comps = calendar.dateComponents([.month, .year], from: date)
        
        return "\(calendar.monthSymbols[comps.month!-1]) \(comps.year!)"
    }
}



extension Date {
    
    
    var businessMonth: BusinessMonth {
        
        let calendar = Calendar.current
        
        return try! BusinessMonth(
            fromYear: calendar.component(.year, from: self),
            month: calendar.component(.month, from: self)
        )
    }
}



extension BusinessMonth {
    
    
    static var current: BusinessMonth {
        
        Date().businessMonth
    }
}
