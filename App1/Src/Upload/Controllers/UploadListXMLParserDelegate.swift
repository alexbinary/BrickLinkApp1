
import Foundation



class UploadListXMLParserDelegate : NSObject, XMLParserDelegate {

    
    var decodedUploadItems: [UploadItem] = []
    
    
    private var ref: String = ""
    private var colorId: String = ""
    private var type: String = ""
    private var qty: String = ""
    private var unitPrice: String = ""
    private var condition: String = ""
    private var comment: String = ""
    
    private var currentElementName: String? = nil
    
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        self.currentElementName = elementName
    }
    
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if let elementName = self.currentElementName {
            switch elementName {
                
            case "ITEMID": ref = string
            case "COLOR": colorId = string
            case "ITEMTYPE": type = string
            case "QTY": qty = string
            case "PRICE": unitPrice = string
            case "CONDITION": condition = string
            case "DESCRIPTION": comment = string
            
            default: break
            }
        }
    }
    
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        self.currentElementName = nil
        
        guard elementName == "ITEM" else { return }
        
        let type: ItemType? = {
            switch self.type {
            case "P": ItemType.part
            default: nil
            }
        }()
        let ref = self.ref
        let colorId = self.colorId
        let qty = Int(self.qty)
        let condition = ItemCondition(rawValue: self.condition)
        let unitPrice = Float(self.unitPrice)
        let comment = self.comment
        
        defer {
            self.ref = ""
            self.colorId = ""
            self.type = ""
            self.qty = ""
            self.unitPrice = ""
            self.condition = ""
            self.comment = ""
        }
        
        guard let type = type else {
            print("could not parse type: \(self.type)")
            return
        }
            
        self.decodedUploadItems.append(UploadItem(
            type: type,
            ref: ref,
            name: nil,
            colorId: colorId,
            qty: qty,
            condition: condition,
            comment: comment,
            unitPrice: unitPrice
        ))
    }
}
