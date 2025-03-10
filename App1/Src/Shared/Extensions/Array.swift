
import Foundation



extension Array {

    
    func limit(_ n: Int) -> Self {
        
        if self.isEmpty {
            return []
        }
        let end = Swift.min(n - 1, self.count - 1)
        return Array(self[0...end])
    }
}



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
    
    
    var unique: Self { stableUniqueByFirstOccurence }
}
