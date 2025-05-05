
import SwiftUI



struct InventoryLocationItemsView<Content: View>: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    let highlightItems: Set<InventoryItem.ID>
    
    let itemsLimit = 50
    let columnsCount: Int
    
    @ViewBuilder
    let itemViewBuilder: (InventoryItem, any View) -> Content
    
    
    init(items: [InventoryItem], highlightItems: Set<InventoryItem.ID> = [], columnsCount: Int = 4, itemViewBuilder: @escaping (InventoryItem, any View) -> Content) {
        
        self.items = items.sorted(by: { a,b in highlightItems.contains(a.id) })
        self.highlightItems = highlightItems
        self.columnsCount = columnsCount
        self.itemViewBuilder = itemViewBuilder
    }


    var body: some View {

        LazyVGrid(columns: Array(repeating: .init(.fixed(84)), count: columnsCount)) {
            
            ForEach(items.limit(itemsLimit)) { item in
                itemViewBuilder(item, view(for: item, highlighted: highlightItems.contains(item.id)))
            }
            
            if items.count > itemsLimit {
                Text("\(items.count-itemsLimit) more")
            }
        }
        .fixedSize()
    }
    
    
    @ViewBuilder
    func view(for item: InventoryItem, highlighted: Bool) -> some View {
        
        let view =
            ZStack(alignment: .bottomTrailing) {
                CatalogImage(inventoryItem: item)
                    .border(item.condition.color, width: highlighted ? 4 : 2)
                Text("x \(item.quantity)")
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                    .clipShape(Capsule())
                    .padding(4)
            }
            .help("""
                \(item.ref)
                \(item.name.htmlUnescape())
                \(catalog.colorName(forLegoColorId: item.colorId))
                \(item.condition.name.uppercased())
                """
            )
        
        if highlighted {
            view
                .rotationEffect(.degrees(-10))
                .shadow(radius: 4)
        } else {
            view
        }
    }
}
