
import SwiftUI



struct InventoryLocationItemsView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    
    let itemsLimit = 50


    var body: some View {

        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4)) {
            
            ForEach(items.limit(itemsLimit)) { item in
                view(for: item)
            }
            
            if items.count > itemsLimit {
                Text("\(items.count-itemsLimit) more")
            }
        }
    }
    
    
    @ViewBuilder
    func view(for item: InventoryItem) -> some View {
        
        ZStack(alignment: .bottomTrailing) {
            CatalogImage(inventoryItem: item)
                .border(color(for: item.condition), width: 2)
            Text("x \(item.quantity)")
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                .clipShape(Capsule())
                .padding(4)
        }
        .help(catalog.colorName(forLegoColorId: item.colorId))
    }
    
    
    func color(for condition: String) -> Color {
        switch condition {
        case "U": return .red
        case "N": return .blue
        default: return .clear
        }
    }
}
