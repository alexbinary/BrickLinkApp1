
import Foundation



public protocol IsOneOfAble {
    
    
    func isOneOf(_ elements: [Self]) -> Bool
    func isNotOneOf(_ elements: [Self]) -> Bool
    
    func isOneOf(_ elements: Self...) -> Bool
    func isNotOneOf(_ elements: Self...) -> Bool
}



extension IsOneOfAble where Self: Equatable {
    
    
    public func isOneOf(_ elements: [Self]) -> Bool {
        
        elements.contains(self)
    }
    
    
    public func isNotOneOf(_ elements: [Self]) -> Bool {
        
        !self.isOneOf(elements)
    }
    
    
    public func isOneOf(_ elements: Self...) -> Bool {
        
        elements.contains(self)
    }
    
    
    public func isNotOneOf(_ elements: Self...) -> Bool {
        
        !self.isOneOf(elements)
    }
}



extension Int: IsOneOfAble { }
