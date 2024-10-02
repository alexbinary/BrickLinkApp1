


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
    
    
    var grouppedByBusinessMonth: [(month: BusinessMonth, elements: [Self.Element])] {
        
        let months = self.map { $0.date.businessMonth } .stableUniqueByFirstOccurence
        
        return months.map { month in
            
            return (
                month: month,
                elements: self.filter { $0.date.businessMonth == month }
            )
        }
    }
}



extension Array where Element == (month: String, elements: [OrderDetails]) {
    
    
    subscript(_ month: String) -> [OrderDetails] {
        
        return self.first(where: { $0.month == month })?.elements ?? []
    }
}



extension Array where Element == (month: BusinessMonth, elements: [OrderDetails]) {
    
    
    subscript(_ month: BusinessMonth) -> [OrderDetails] {
        
        return self.first(where: { $0.month == month })?.elements ?? []
    }
}
