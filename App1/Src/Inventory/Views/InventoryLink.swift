
import SwiftUI




struct InventoryLink<Label>: View where Label: View {
    
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    

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



#Preview(traits: .env) {
    
    InventoryLink(inventoryItemId: "") { Text("Link") }
}
