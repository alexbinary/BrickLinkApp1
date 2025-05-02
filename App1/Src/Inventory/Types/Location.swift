
import Foundation



struct Location: CustomStringConvertible {
    
    
    let meuble: Meuble
    let tiroir: Int
    let colonne: Int?
    let ligne: Int?
    let ab: AB?
    
    
    var textRepresentation: String {
        
        var str = "\(meuble)\(tiroir)"
        
        if let colonne = colonne {
            str += "-\(colonne)"
        }
        if let ligne = ligne {
            str += ".\(ligne)"
        }
        if let ab = ab {
            str += "\(ab)"
        }
        return str
    }
    
    var description: String { textRepresentation }
    
    
    init?(from str: String) {
        
        let scanner = Scanner(string: str)
        
        guard let charMeuble = scanner.scanCharacter(),
              let valueMeuble = Meuble(rawValue: String(charMeuble)) else { return nil }
        self.meuble = valueMeuble
        
        guard let valueTiroir = scanner.scanInt(), valueTiroir > 0 else { return nil }
        self.tiroir = valueTiroir
        
        if scanner.isAtEnd {
            self.colonne = nil
            self.ligne = nil
            self.ab = nil
            return
        }
        
        guard let char = scanner.scanCharacter(), char == "-" else { return nil }
        
        guard let valueColonne = scanner.scanInt(), valueColonne > 0 else { return nil }
        self.colonne = valueColonne
        
        guard let char = scanner.scanCharacter(), char == "." else { return nil }
        
        guard let valueLigne = scanner.scanInt(), valueLigne > 0 else { return nil }
        self.ligne = valueLigne
        
        if scanner.isAtEnd {
            self.ab = nil
            return
        }
        
        guard let char = scanner.scanCharacter(),
              let valueAB = AB(rawValue: String(char)) else { return nil }
        self.ab = valueAB
        
        guard scanner.isAtEnd else { return nil }
    }
}

        

enum Meuble: String {
    
    case A, B, C, D, E, F
}

enum AB: String {
    
    case a, b
}



extension Location: Comparable {
    
    static func < (lhs: Location, rhs: Location) -> Bool {
        
        if lhs.meuble.rawValue != rhs.meuble.rawValue {
            return lhs.meuble.rawValue < rhs.meuble.rawValue
        }
        
        if lhs.tiroir != rhs.tiroir {
            return lhs.tiroir < rhs.tiroir
        }
        
        if lhs.colonne != rhs.colonne {
            return (lhs.colonne ?? Int.max) < (rhs.colonne ?? Int.max)
        }
        
        if lhs.ligne != rhs.ligne {
            return (lhs.ligne ?? Int.max) < (rhs.ligne ?? Int.max)
        }
        
        if lhs.ab != rhs.ab {
            return (lhs.ab?.rawValue ?? "") < (rhs.ab?.rawValue ?? "")
        }
        
        return false
    }
}
