


import Foundation



protocol Datable {
    
    var date: Date { get }
}



extension Array where Element: Datable {
    
    
    var grouppedByMonth: [(month: String, elements: [Self.Element])] {
        
        let withMonth: [(month: String, element: Self.Element)] = self.map {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.month, .year], from: $0.date)
            let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
            
            return (month: month, element: $0)
        }
        
        return withMonth.map { $0.month } .stableUniqueByFirstOccurence .map { month in
            
            return (
                month: month,
                elements: withMonth.filter { $0.month == month } .map { $0.element }
            )
        }
    }
}
