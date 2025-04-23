
import Foundation



struct Location {
    
    
    let meuble: Meuble
    let tiroir: Int
    let colonne: Int?
    let ligne: Int?
    let ab: AB?
    
    
    var description: String {
        
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
    
    
    init?(from str: String) {
        
        let strFirstLevelParts = str.split(separator: "-")
        if strFirstLevelParts.count < 1 || strFirstLevelParts.count > 2 {
            return nil
        }
        let strMeubleEtTiroir = strFirstLevelParts[0]
        
        let strMeuble = String(strMeubleEtTiroir.first!)
        if let valueMeuble = Meuble(rawValue: strMeuble) {
            self.meuble = valueMeuble
        } else {
            return nil
        }
        
        let strTiroir = strMeubleEtTiroir[(strMeubleEtTiroir.index(after: strMeubleEtTiroir.startIndex))...]
        if let valueTiroir = Int(strTiroir) {
            self.tiroir = valueTiroir
        } else {
            return nil
        }
        
        if strFirstLevelParts.count < 2 {
            
            self.colonne = nil
            self.ligne = nil
            self.ab = nil
            
        } else {
            
            let strColonneLigneAB = strFirstLevelParts[1]
            
            let strColonneLigneABParts = strColonneLigneAB.split(separator: ".")
            if strColonneLigneABParts.count != 2 {
                return nil
            }
            
            let strColonne = String(strColonneLigneABParts[0])
            if let valueColonne = Int(strColonne) {
                self.colonne = valueColonne
            } else {
                return nil
            }
            
            let strLigneAB = String(strColonneLigneABParts[1])
            
            let scannerLigneAB = Scanner(string: strLigneAB)
            if let valueLigne = scannerLigneAB.scanInt() {
                self.ligne = valueLigne
            } else {
                return nil
            }
            
            if let charAB = scannerLigneAB.scanCharacter(), let valueAB = AB(rawValue: String(charAB)) {
                self.ab = valueAB
            } else {
                self.ab = nil
            }
        }
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
