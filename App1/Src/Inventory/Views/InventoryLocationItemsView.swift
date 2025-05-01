
import SwiftUI



struct InventoryLocationItemsView<Content: View>: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    
    let itemsLimit = 50
    let columnsCount: Int
    
    @ViewBuilder
    let itemViewBuilder: (InventoryItem, any View) -> Content
    
    
    init(items: [InventoryItem], columnsCount: Int = 4, itemViewBuilder: @escaping (InventoryItem, any View) -> Content) {
        
        self.items = items
        self.columnsCount = columnsCount
        self.itemViewBuilder = itemViewBuilder
    }


    var body: some View {

        LazyVGrid(columns: Array(repeating: .init(.fixed(84)), count: columnsCount)) {
            
            ForEach(items.limit(itemsLimit)) { item in
                itemViewBuilder(item, view(for: item))
            }
            
            if items.count > itemsLimit {
                Text("\(items.count-itemsLimit) more")
            }
        }
        .fixedSize()
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
    
    
    func color(for condition: ItemCondition) -> Color {
        switch condition {
        case .used: return .red
        case .new: return .blue
        }
    }
}
