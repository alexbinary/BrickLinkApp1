
import Foundation
import SwiftUI



@Observable
class InventoryStore {
    
    
    private let dataStore: DataStore
    private let blCredentials: BrickLinkAPICredentials
    
    
    init(dataStore: DataStore, blCredentials: BrickLinkAPICredentials) {
        self.dataStore = dataStore
        self.blCredentials = blCredentials
    }
    
    
    // MARK: - Inventory
    
    
    public var inventories: [InventoryItem] {
        
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
        
        return inventories.first {
            
            $0.type == type
            && $0.ref == ref
            && $0.description == (comment ?? "")
            && $0.colorId == colorId
            && $0.condition == condition
        }
    }
    
    
    public func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        return inventories.first {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.colorId == uploadItem.colorId
            && $0.condition == uploadItem.condition
        }
    }
    
    
    public func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        return inventories.filter {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.condition == uploadItem.condition
        }
    }
    
    
    public func loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await BrickLinkAPIClient.fetchInventories(using: blCredentials)
        
        let inventories = blInventories.map {
            InventoryItem(fromBl: $0)
        }
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    public func loadInventory(withId id: InventoryItem.ID) async {
        
        let blInventory = await BrickLinkAPIClient.fetchInventory(withId: id, using: blCredentials)
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
        
        let inventories = await BrickLinkAPIClient.fetchInventories(matchingItemType: uploadItem.type, matchingColorId: uploadItem.colorId, using: blCredentials)
            
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
        
        let blInventory = await BrickLinkAPIClient.createInventory(
            
            ref: ref,
            type: type,
            colorId: colorId,
            quantity: quantity,
            unitPrice: unitPrice,
            condition: condition,
            description: description,
            remarks: remarks,
            
            using: blCredentials
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
        
        await BrickLinkAPIClient.updateInventory(
            
            id: id,
        
            addQuantity: addQuantity,
            unitPrice: unitPrice,
            remarks: remarks,
            
            using: blCredentials
        )
        
        await self.reloadInventory(withId: id)
    }
}
