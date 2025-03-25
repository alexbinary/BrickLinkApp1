
import Foundation
import SwiftUI
import Core



@Observable
class InventoryCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Inventory
    
    
    public var allInventories: [InventoryItem] {
        
        dataStore.inventories
    }
    
    
    public func inventory(withId id: InventoryItem.ID) -> InventoryItem? {
        
        dataStore.inventories.first { $0.id == id }
    }
    
    
    public func inventory(
        
        forType type: BrickLinkItemType,
        ref: String,
        comment: String?,
        colorId: String,
        condition: String
    
    ) -> InventoryItem? {
        
        return allInventories.first {
            
            $0.type == type
            && $0.ref == ref
            && $0.description == (comment ?? "")
            && $0.colorId == colorId
            && $0.condition == condition
        }
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        return allInventories.first {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.colorId == uploadItem.colorId
            && $0.condition == uploadItem.condition
        }
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        return allInventories.filter {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.condition == uploadItem.condition
        }
    }
    
    
    public func loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await brickLinkAPIClient.fetchInventories()
        
        let inventories = blInventories.map { InventoryItem(fromBl: $0) }
        
        print("loaded \(inventories.count) inventories")
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    public func loadInventory(withId id: InventoryItem.ID) async {
        
        print("Loading inventory \(id)")
        
        let blInventory = await brickLinkAPIClient.fetchInventory(withId: id)
        let inventory = InventoryItem(fromBl: blInventory)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    public func reloadInventories() async {
        
        if !dataStore.inventories.isEmpty {
        
            await loadInventories()
        }
    }
    
    
    public func reloadInventory(withId id: InventoryItem.ID) async {
        
        if dataStore.inventories.contains(where: { $0.id == id }) {
            
            await loadInventory(withId: id)
        }
    }
    
    
    public func getInventory(for uploadItem: UploadItem) async -> InventoryItem? {
        
        let inventories = await brickLinkAPIClient.fetchInventories(matchingItemType: uploadItem.type, matchingColorId: uploadItem.colorId)
            
        if let inv = inventories.first(where: { inv in
            
            inv.item.type == uploadItem.type
            && inv.item.no == uploadItem.ref
            && "\(inv.colorId)" == uploadItem.colorId
            && inv.newOrUsed == uploadItem.condition
            && (inv.description ?? "") == (uploadItem.comment ?? "")
        }) {
            return InventoryItem(fromBl: inv)
        }
        
        return nil
    }
    
    
    public func createInventory(
        
        ref: String,
        type: BrickLinkItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String
        
    ) async -> InventoryItem? {
        
        let blInventory = await brickLinkAPIClient.createInventory(
            
            ref: ref,
            type: type,
            colorId: colorId,
            quantity: quantity,
            unitPrice: unitPrice,
            condition: condition,
            description: description,
            remarks: remarks
        )
        
        let inventory = InventoryItem(fromBl: blInventory)
        
        await self.reloadInventories()
        
        return inventory
    }
    
    
    public func updateInventory(
        
        id: InventoryItem.ID,
        
        addQuantity: Int,
        unitPrice: Float? = nil,
        remarks: String? = nil
    
    ) async {
        
        await brickLinkAPIClient.updateInventory(
            
            id: id,
        
            addQuantity: addQuantity,
            unitPrice: unitPrice,
            remarks: remarks
        )
        
        await self.reloadInventory(withId: id)
    }
}



extension InventoryItem {
    
    
    init(fromBl bl: BrickLinkInventoryItem) {
        
        self.id = "\(bl.inventoryId)"
        self.condition = bl.newOrUsed
        self.colorId = "\(bl.colorId)"
        self.ref = bl.item.no
        self.name = bl.item.name
        self.type = bl.item.type
        self.description = bl.description ?? ""
        self.remarks = bl.remarks ?? ""
        self.quantity = bl.quantity
        self.unitPrice = bl.unitPrice.floatValue
    }
}
