
import Foundation



struct UploadedItem: Identifiable, Codable, Equatable {
    
    var id = UUID()
    let type: ItemType
    let ref: String
    let name: String?
    let colorId: LegoColor.ID
    let qtyBefore: Int?
    let qtyAfter: Int
    let condition: ItemCondition
    let comment: String?
    let remarksBefore: String?
    let remarksAfter: String
    let unitPriceBefore: Float?
    let unitPriceAfter: Float
    let inventoryId: InventoryItem.ID
    let uploadDate: Date
    let inventoryStatus: UploadInventoryStatus
}


extension UploadedItem: Datable {
    
    var date: Date { uploadDate }
}


enum UploadInventoryStatus: String, Codable {
    
    case created
    case updated
}


extension UploadedItem: PartDescriptible {
    
    var partDescriptor: PartDescriptor {
        .init(
            item_type: type,
            item_ref: ref,
            item_colorId: colorId,
            item_condition: condition
        )
    }
}



extension UploadedItem {
    
    
    @MainActor
    func matches(_ rawSearchText: String, _ catalog: CatalogProtocol) -> Bool {
        
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            return true
        }
        
        let searchableText = searchableText(catalog)
        
        return searchableText.contains(searchText)
    }
    
    
    @MainActor
    func searchableText(_ catalog: CatalogProtocol) -> String {
        
        [
            rawSearchableText_type,
            rawSearchableText_ref,
            rawSearchableText_name,
            catalog.colorName(forLegoColorId: colorId),
            rawSearchableText_qtyBefore,
            rawSearchableText_qtyAfter,
            rawSearchableText_condition,
            rawSearchableText_comment,
            rawSearchableText_remarksBefore,
            rawSearchableText_remarksAfter,
            rawSearchableText_unitPriceBefore,
            rawSearchableText_unitPriceAfter,
            rawSearchableText_inventoryId,
            rawSearchableText_inventoryStatus,
            rawSearchableText_uploadDate,
            
        ].map { $0.lowercased() } .joined(separator: " ")
    }
    
    
    var rawSearchableText_type: String {
        
        type.rawValue
    }
    
    var rawSearchableText_ref: String {
    
        ref
    }
    
    var rawSearchableText_name: String {
    
        name ?? ""
    }
    
    var rawSearchableText_qtyBefore: String {
    
        if let qty = qtyBefore {
            "\(qty)"
        } else {
            ""
        }
    }
    
    var rawSearchableText_qtyAfter: String {
    
        "\(qtyAfter)"
    }
    
    var rawSearchableText_condition: String {
    
        condition.name
    }
    
    var rawSearchableText_comment: String {
    
        comment ?? ""
    }
    
    var rawSearchableText_remarksBefore: String {
    
        remarksBefore ?? ""
    }
    
    var rawSearchableText_remarksAfter: String {
        
        remarksAfter
    }
    
    var rawSearchableText_unitPriceBefore: String {
        
        if let price = unitPriceBefore {
            priceFormatter.string(from: NSNumber(value: price)) ?? ""
        } else {
            ""
        }
    }
    
    var rawSearchableText_unitPriceAfter: String {
        
        priceFormatter.string(from: NSNumber(value: unitPriceAfter)) ?? ""
    }
    
    var rawSearchableText_inventoryId: String {
        
        inventoryId
    }
    
    var rawSearchableText_uploadDate: String {
        
        DateFormatter.localizedString(
            from: uploadDate,
            dateStyle: .full, timeStyle: .none
        )
    }
    
    var rawSearchableText_inventoryStatus: String {
        
        inventoryStatus.rawValue
    }
    
    
    var priceFormatter: NumberFormatter {
        
        let f = NumberFormatter()
        f.minimumFractionDigits = 4
        f.maximumFractionDigits = 4
        return f
    }
}
