
import SwiftUI




struct InventoryLink<Label>: View where Label: View {
    
    
    @Environment(InventoryStore.self)
    var inventoryStore
    

    let inventoryItemId: InventoryItem.ID
    let label: () -> Label
    
    init(_ inventoryItem: InventoryItem, label: @escaping () -> Label) {
        self.inventoryItemId = inventoryItem.id
        self.label = label
    }
    
    init(inventoryItemId: InventoryItem.ID, label: @escaping () -> Label) {
        self.inventoryItemId = inventoryItemId
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: inventoryStore.url(forInventoryItemWithId: inventoryItemId)!, label: label)
    }
}



#Preview {
    
    let env = createEnv()
    let inventory = env.stores.inventory.allInventories.first!
    
    InventoryLink(inventory) { Text(inventory.id) }
}
