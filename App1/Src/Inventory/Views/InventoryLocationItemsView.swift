
import SwiftUI



struct InventoryLocationItemsView<Content: View>: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let items: [InventoryItem]
    let highlightItems: Set<InventoryItem.ID>
    
    let itemsLimit = 50
    let columnsCount: Int
    
    let splitByRemarks: Bool
    
    @ViewBuilder
    let itemViewBuilder: (InventoryItem, any View) -> Content
    
    
    init(items: [InventoryItem], highlightItems: Set<InventoryItem.ID> = [], columnsCount: Int = 4, splitByRemarks: Bool = false, itemViewBuilder: @escaping (InventoryItem, any View) -> Content) {
        
        self.items = items.sorted(by: { a,b in highlightItems.contains(a.id) })
        self.highlightItems = highlightItems
        self.columnsCount = columnsCount
        self.splitByRemarks = splitByRemarks
        self.itemViewBuilder = itemViewBuilder
    }


    var body: some View {

        Group {
            
            if splitByRemarks {
                
                let itemsByRemark = Dictionary(grouping: items, by: { $0.remarks})
                let remarks = Array(itemsByRemark.keys).sorted(
                    tryUsing: { Location(from: $0) },
                    sortNilFirst: false
                )
                
                VStack(spacing: 12) {
                    
                    ForEach(remarks, id: \.self) { remark in
                        
                        VStack(alignment: .leading) {
                            
                            let items = itemsByRemark[remark]!
                            
                            HStack {
                                if let loc = Location(from: remark) {
                                    Text("\(loc)").bold()
                                } else if remark.isEmpty {
                                    Text("no remarks").foregroundStyle(.secondary).italic()
                                } else {
                                    Text(remark)
                                }
                                Text("\(items.count) items").foregroundStyle(.secondary)
                            }
                            
                            view(for: items)
                        }
                    }
                }
                
            } else {
                
                view(for: items)
            }
        }
        .fixedSize()
    }
    
    
    @ViewBuilder
    func view(for items: [InventoryItem]) -> some View {
        
        LazyVGrid(columns: Array(repeating: .init(.fixed(84)), count: columnsCount)) {
            
            ForEach(items.limit(itemsLimit)) { item in
                itemViewBuilder(item, view(for: item, highlighted: highlightItems.contains(item.id)))
            }
            
            if items.count > itemsLimit {
                Text("\(items.count-itemsLimit) more")
            }
        }
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
