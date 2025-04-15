
import Foundation



public struct UploadedItem: Identifiable, Codable, Equatable {
    
    public var id = UUID()
    public let type: ItemType
    public let ref: String
    public let name: String?
    public let colorId: LegoColor.ID
    public let qtyBefore: Int?
    public let qtyAfter: Int
    public let condition: String
    public let comment: String?
    public let remarksBefore: String?
    public let remarksAfter: String
    public let unitPriceBefore: Float?
    public let unitPriceAfter: Float
    public let inventoryId: InventoryItem.ID
    public let uploadDate: Date
    public let inventoryStatus: UploadInventoryStatus
    
    public init(
        id: UUID = UUID(),
        type: ItemType,
        ref: String,
        name: String?,
        colorId: LegoColor.ID,
        qtyBefore: Int?,
        qtyAfter: Int,
        condition: String,
        comment: String?,
        remarksBefore: String?,
        remarksAfter: String,
        unitPriceBefore: Float?,
        unitPriceAfter: Float,
        inventoryId: InventoryItem.ID,
        uploadDate: Date,
        inventoryStatus: UploadInventoryStatus
    ) {
        self.id = id
        self.type = type
        self.ref = ref
        self.name = name
        self.colorId = colorId
        self.qtyBefore = qtyBefore
        self.qtyAfter = qtyAfter
        self.condition = condition
        self.comment = comment
        self.remarksBefore = remarksBefore
        self.remarksAfter = remarksAfter
        self.unitPriceBefore = unitPriceBefore
        self.unitPriceAfter = unitPriceAfter
        self.inventoryId = inventoryId
        self.uploadDate = uploadDate
        self.inventoryStatus = inventoryStatus
    }
}


extension UploadedItem: Datable {
    
    public var date: Date { uploadDate }
}


public enum UploadInventoryStatus: String, Codable {
    
    case created
    case updated
}



extension UploadedItem {
    
    
    @MainActor
    func matches(_ rawSearchText: String, _ catalog: Catalog) -> Bool {
        
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty {
            return true
        }
        
        let searchableText = searchableText(catalog)
        
        return searchableText.contains(searchText)
    }
    
    
    @MainActor
    func searchableText(_ catalog: Catalog) -> String {
        
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
    
        condition
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
