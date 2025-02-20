
import Foundation



protocol IsOneOfAble {
    
    
    func isOneOf(_ elements: [Self]) -> Bool
    func isNotOneOf(_ elements: [Self]) -> Bool
    
    func isOneOf(_ elements: Self...) -> Bool
    func isNotOneOf(_ elements: Self...) -> Bool
}



extension IsOneOfAble where Self: Equatable {
    
    
    func isOneOf(_ elements: [Self]) -> Bool {
        
        elements.contains(self)
    }
    
    
    func isNotOneOf(_ elements: [Self]) -> Bool {
        
        !self.isOneOf(elements)
    }
    
    
    func isOneOf(_ elements: Self...) -> Bool {
        
        elements.contains(self)
    }
    
    
    func isNotOneOf(_ elements: Self...) -> Bool {
        
        !self.isOneOf(elements)
    }
}
