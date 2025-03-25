import Foundation



public protocol Datable {
    
    var date: Date { get }
}



extension Array where Element: Datable {
    
    
    public var grouppedByDay: [(day: String, elements: [Self.Element])] {
        
        let withDay: [(day: String, element: Self.Element)] = self.map {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.day, .month, .year], from: $0.date)
            let day = "\(comps.day!) \(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
            
            return (day: day, element: $0)
        }
        
        return withDay.map { $0.day } .unique .map { day in
            
            return (
                day: day,
                elements: withDay.filter { $0.day == day } .map { $0.element }
            )
        }
    }
    
    
    public var grouppedByMonth: [(month: String, elements: [Self.Element])] {
        
        let withMonth: [(month: String, element: Self.Element)] = self.map {
            
            let cal = Calendar.current
            
            let comps = cal.dateComponents([.month, .year], from: $0.date)
            let month = "\(cal.monthSymbols[comps.month!-1]) \(comps.year!)"
            
            return (month: month, element: $0)
        }
        
        return withMonth.map { $0.month } .unique .map { month in
            
            return (
                month: month,
                elements: withMonth.filter { $0.month == month } .map { $0.element }
            )
        }
    }
    
    
    public var grouppedByBusinessMonth: [(month: BusinessMonth, elements: [Self.Element])] {
        
        let months = self.map { $0.date.businessMonth } .unique
        
        return months.map { month in
            
            return (
                month: month,
                elements: self.filter { $0.date.businessMonth == month }
            )
        }
    }
}



extension Array where Element == (month: String, elements: [OrderDetails]) {
    
    
    public subscript(_ month: String) -> [OrderDetails] {
        
        return self.first(where: { $0.month == month })?.elements ?? []
    }
}



extension Array where Element == (month: BusinessMonth, elements: [OrderDetails]) {
    
    
    public subscript(_ month: BusinessMonth) -> [OrderDetails] {
        
        return self.first(where: { $0.month == month })?.elements ?? []
    }
    
    
    public var withAllMonthsToCurrent: [(month: BusinessMonth, elements: [OrderDetails])] {
        
        let orderMonths = self.map { $0.month } .unique.sorted()
        
        let allMonths: [BusinessMonth] = {
            if let first = orderMonths.first {
                return BusinessMonth.allMonths(from: first, to: .current)
            } else {
                return []
            }
        }()
        
        return allMonths.map { (month: $0, elements: self[$0]) }
    }
}
