
import Foundation



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
}
