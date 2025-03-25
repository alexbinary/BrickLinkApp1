
import SwiftUI
import Core



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
    
    let env = createEnv()
    let inventory = env.stores.inventory.allInventories.first!
    
    InventoryLink(inventory) { Text(inventory.id) }
}
