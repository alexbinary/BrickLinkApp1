
import Foundation



struct InventoryItem: Identifiable, Equatable, Codable {
    
    
    let id: String
    let condition: ItemCondition
    let colorId: String
    let ref: String
    let name: String
    let type: ItemType
    let description: String
    let remarks: String
    let quantity: Int
    let unitPrice: Float
}



extension InventoryItem: PartDescriptible {
    
    
    var partDescriptor: PartDescriptor {
        .init(
            type: type,
            ref: ref,
            comment: description,
            colorId: colorId,
            condition: condition
        )
    }
}



extension InventoryItem {

    
    init(fromBl bl: BrickLinkInventoryItem) {
        self.init(
            id: "\(bl.inventoryId)",
            condition: .init(fromBl: bl.newOrUsed),
            colorId: "\(bl.colorId)",
            ref: bl.item.no,
            name: bl.item.name,
            type: ItemType(fromBl: bl.item.type),
            description: bl.description ?? "",
            remarks: bl.remarks ?? "",
            quantity: bl.quantity,
            unitPrice: bl.unitPrice.floatValue
        )
    }
}



extension Array where Element == InventoryItem {
    
    
    func sortedByLocation() -> Self {
        
        self.sorted(
            tryUsing: { Location(from: $0.remarks) },
            ifNilTry: { $0.remarks },
            sortNilFirst: true
        )
    }
}



extension InventoryItem {
    
    
    @MainActor
    func matches(_ rawSearchText: String, _ searchTokens: [SearchToken], _ catalog: CatalogProtocol) -> Bool {
        
        let searchText = rawSearchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        if searchText.isEmpty && searchTokens.isEmpty {
            return true
        }
        
        let searchTerms = searchText.split(separator: " ").map { String($0) }
        
        return
            searchTerms.allSatisfy { self.matches($0, catalog) }
            &&
            searchTokens.allSatisfy { self.matches($0, catalog) }
    }
    
    
    @MainActor
    func matches(_ searchTerm: String, _ catalog: CatalogProtocol) -> Bool {
        
        if searchTerm.isEmpty {
            return true
        }
        
        let searchableText = searchableText(catalog)
        
        return searchableText.contains(searchTerm)
    }
    
    
    @MainActor
    func matches(_ token: SearchToken, _ catalog: CatalogProtocol) -> Bool {
        
        switch token {
            
        case .locationIs(let location):
            return remarks == location.description
            
        case .locationContains(let str):
            return rawSearchableText_remarks.lowercased().contains(str.lowercased())
        
        case .refIs(let ref):
            return self.ref == ref
            
        case .refContains(let str):
            return rawSearchableText_ref.lowercased().contains(str.lowercased())
        }
    }
    
    
    @MainActor
    func searchableText(_ catalog: CatalogProtocol) -> String {
        
        [
            rawSearchableText_id,
            rawSearchableText_condition,
            catalog.colorName(forLegoColorId: colorId),
            rawSearchableText_ref,
            rawSearchableText_name,
            rawSearchableText_type,
            rawSearchableText_description,
            rawSearchableText_remarks,
            rawSearchableText_quantity,
            rawSearchableText_unitPrice,
            
        ].map { $0.lowercased() } .joined(separator: " ")
    }
    
    
    var rawSearchableText_id: String {
        
        id
    }
    
    var rawSearchableText_condition: String {
    
        condition.name
    }
    
    var rawSearchableText_ref: String {
    
        ref
    }
    
    var rawSearchableText_name: String {
    
        name
    }
    
    var rawSearchableText_type: String {
        
        type.rawValue
    }
    
    var rawSearchableText_description: String {
    
        description
    }
    
    var rawSearchableText_remarks: String {
    
        remarks
    }
    
    var rawSearchableText_quantity: String {
    
        "\(quantity)"
    }
    
    var rawSearchableText_unitPrice: String {
        
        priceFormatter.string(from: NSNumber(value: unitPrice)) ?? ""
    }
    
    
    var priceFormatter: NumberFormatter {
        
        let f = NumberFormatter()
        f.minimumFractionDigits = 4
        f.maximumFractionDigits = 4
        return f
    }
}
