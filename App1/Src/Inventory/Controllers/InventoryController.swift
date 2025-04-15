import Foundation
import SwiftUI



class InventoryController {
    
    
    private let dataStore: DataStore
    private let updateController: UpdateController
    private let brickLinkAPIClient: BrickLinkAPIClient

    
    init(_ dataStore: DataStore, _ updateController: UpdateController, _ brickLinkAPIClient: BrickLinkAPIClient) {
        
        self.dataStore = dataStore
        self.updateController = updateController
        self.brickLinkAPIClient = brickLinkAPIClient
    }
    
    
    // MARK: - Inventory
    
    
    var allInventories: [InventoryItem] {
        
        dataStore.inventories
    }
    
    
    var hasInventories: Bool {
        
        !dataStore.inventories.isEmpty
    }
    
    
    func inventory(withId id: InventoryItem.ID) -> InventoryItem? {
        
        dataStore.inventories.first { $0.id == id }
    }
    
    
    func inventory(
        
        forType type: ItemType,
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
    
    
    func loadInventories(_ refetchStrategy: RefetchStrategy = .forceRefetch, _ operationTag: OperationTag? = nil) async {
        
        await updateController.loadInventories(refetchStrategy, operationTag)
    }
    
    
    func loadInventory(withId inventoryId: InventoryItem.ID, _ refetchStrategy: RefetchStrategy = .forceRefetch) async {
        
        await updateController.loadInventory(withId: inventoryId, refetchStrategy)
    }
    
    
    var isLoadingInventories: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadInventories
    }
    
    
    var isLoadingInventory: Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadInventory
    }
    
    
    func isLoadingInventory(withId inventoryId: InventoryItem.ID) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_loadInventory(withId: inventoryId)
    }


    func invalidateInventories() {

        updateController.invalidateInventories()
    }
    
    
    func invalidateInventory(_ inventoryId: InventoryItem.ID) {

        updateController.invalidateInventory(inventoryId)
    }
    
    
    func createInventory(
        
        ref: String,
        type: ItemType,
        colorId: String,
        quantity: Int,
        unitPrice: Float,
        condition: String,
        description: String?,
        remarks: String
        
    ) async -> InventoryItem? {
        
        let blInventory = await brickLinkAPIClient.createInventory(
            
            ref: ref,
            type: type.brickLinkItemType,
            colorId: colorId,
            quantity: quantity,
            unitPrice: unitPrice,
            condition: condition,
            description: description,
            remarks: remarks
        )
        
        let inventory = InventoryItem(fromBl: blInventory)
        
        updateController.validateInventory(inventory.id)
        
        try! dataStore.setInventory(inventory)
        try! dataStore.save()
        
        return inventory
    }
    
    
    func updateInventory(inventoryId: InventoryItem.ID, addQuantity: Int, unitPrice: Float? = nil, remarks: String? = nil) async {
        
        await updateController.updateInventory(inventoryId: inventoryId, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
    }
}
