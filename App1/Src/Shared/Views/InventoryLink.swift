
import SwiftUI



struct InventoryLink<Label>: View where Label: View {
    
    
    @EnvironmentObject
    var app: AppController

    
    let inventoryItem: InventoryItem
    let label: () -> Label
    
    init(_ inventoryItem: InventoryItem, label: @escaping () -> Label) {
        self.inventoryItem = inventoryItem
        self.label = label
    }
    
    
    var body: some View {

        Link(destination: app.url(forInventoryItemWithId: inventoryItem.id)!, label: label)
    }
}



#Preview {
    let appController = AppController()
    let inventory = appController.inventories.first!
    InventoryLink(inventory) { Text(inventory.id) }
}
