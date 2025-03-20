
import SwiftUI



struct InventoryLink<Label>: View where Label: View {
    
    
    let inventoryItem: InventoryItem
    let label: () -> Label
    
    init(_ inventoryItem: InventoryItem, label: @escaping () -> Label) {
        self.inventoryItem = inventoryItem
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: BrickLinkUtility.url(forInventoryItemWithId: inventoryItem.id)!, label: label)
    }
}



#Preview {
    
    let stores = createStores()
    
    let inventoryStore = stores.inventory
    
    let inventory = inventoryStore.allInventories.first!
    
    InventoryLink(inventory) { Text(inventory.id) }
}
