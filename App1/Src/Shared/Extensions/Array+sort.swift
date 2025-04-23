


protocol Comparator<T> {
    
    associatedtype T
    
    func areInIncreasingOrder(_ lhs: T, _ rhs: T) -> Bool
}



struct TransformComparator<Base, Transformed: Comparable>: Comparator {
    
    let getValueToCompare: (Base) -> Transformed?
    var order: SortOrder = .increasing
    var nilFirst: Bool = true
    var fallbackComparator: (any Comparator<Base>)? = nil
    
    func areInIncreasingOrder(_ lhs: Base, _ rhs: Base) -> Bool {
        
        let val0 = getValueToCompare(lhs)
        let val1 = getValueToCompare(rhs)
        
        switch (val0, val1) {
            
        case (nil, nil):
            return fallbackComparator?.areInIncreasingOrder(lhs, rhs) ?? true
            
        case (nil, .some):
            return nilFirst
        
        case (.some, nil):
            return !nilFirst
            
        case (.some(let val0), .some(let val1)):
            return order == .increasing ? val0 < val1 : val0 > val1
        }
    }
}



enum SortOrder {
    
    case increasing
    case decreasing
}



extension Array {
    
    
    func sorted(using comparator: any Comparator<Array.Element>) -> [Array.Element] {
        
        self.sorted(by: { comparator.areInIncreasingOrder($0, $1) })
    }
    
    
    func sorted<Primary: Comparable, Fallback: Comparable>(
    
        on getPrimaryValueToCompare: @escaping (Array.Element) -> Primary?,
        ifNilOn getFallbackValueToCompare: @escaping (Array.Element) -> Fallback,
        
        order: SortOrder = .increasing,
        nilFirst: Bool = true
        
    ) -> [Self.Element] {
        
        let comparator = TransformComparator(
            getValueToCompare: getPrimaryValueToCompare, order: order, nilFirst: nilFirst,
            fallbackComparator: TransformComparator(
                getValueToCompare: getFallbackValueToCompare, order: order, nilFirst: nilFirst
            )
        )
        return self.sorted(using: comparator)
    }
}
