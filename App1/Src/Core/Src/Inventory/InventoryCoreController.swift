
import Foundation
import SwiftUI



@Observable
@MainActor
class InventoryCoreController {
    
    
    private let dataStore: DataStore
    private let brickLinkAPIClient: BrickLinkAPIClient
    
    
    init(_ dataStore: DataStore, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Inventory
    
    
    var allInventories: [InventoryItem] {
        
        dataStore.inventories
    }
    
    
    func inventory(withId id: InventoryItem.ID) -> InventoryItem? {
        
        dataStore.inventories.first { $0.id == id }
    }
    
    
    func inventory(
        
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
    
    
    func inventory(for uploadItem: UploadItem) -> InventoryItem? {
        
        return allInventories.first {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.colorId == uploadItem.colorId
            && $0.condition == uploadItem.condition
        }
    }
    
    
    func inventories(forAllColorsOf uploadItem: UploadItem) -> [InventoryItem] {
        
        return allInventories.filter {
            
            $0.type == uploadItem.type
            && $0.ref == uploadItem.ref
            && $0.description == (uploadItem.comment ?? "")
            && $0.condition == uploadItem.condition
        }
    }
    
    
    func loadInventories() async {
        
        print("Loading inventories")
        
        let blInventories = await brickLinkAPIClient.fetchInventories()
        
        let inventories = blInventories.map { InventoryItem(fromBl: $0) }
        
        print("loaded \(inventories.count) inventories")
        
        try! dataStore.setInventories(inventories)
        try! dataStore.save()
    }
    
    
    func loadInventory(withId id: InventoryItem.ID) async {
        
        print("Loading inventory \(id)")
        
        let blInventory = await brickLinkAPIClient.fetchInventory(withId: id)
        let inventory = InventoryItem(fromBl: blInventory)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
    }
    
    
    func reloadInventories() async {
        
        if !dataStore.inventories.isEmpty {
        
            await loadInventories()
        }
    }
    
    
    func reloadInventory(withId id: InventoryItem.ID) async {
        
        if dataStore.inventories.contains(where: { $0.id == id }) {
            
            await loadInventory(withId: id)
        }
    }
    
    
    func getInventory(for uploadItem: UploadItem) async -> InventoryItem? {
        
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
    
    
    func createInventory(
        
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
    
    
    func updateInventory(
        
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
        self.init(
            id: "\(bl.inventoryId)",
            condition: bl.newOrUsed,
            colorId: "\(bl.colorId)",
            ref: bl.item.no,
            name: bl.item.name,
            type: bl.item.type,
            description: bl.description ?? "",
            remarks: bl.remarks ?? "",
            quantity: bl.quantity,
            unitPrice: bl.unitPrice.floatValue
        )
    }
}
