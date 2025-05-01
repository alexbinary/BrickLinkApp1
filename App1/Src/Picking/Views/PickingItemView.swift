
import SwiftUI




struct PickingItemView: View {
    
    
    @Environment(\.pickingStore)
    var pickingStore: PickingStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let item: OrderItem
    let button: ButtonType
    
    init(_ item: OrderItem, button: ButtonType) {
        self.item = item
        self.button = button
    }
        
    
    var body: some View {
        
        HStack(spacing: 48) {
                
            HStack(alignment: .top) {

                VStack {

                    CatalogImage(orderItem: item)
                        .border(item.condition.color, width: 2)
                    
                    Text(item.condition.name.uppercased())
                        .font(.title3)
                        .foregroundStyle(item.condition.color)
                        .fontWeight(.bold)
                }
                
                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        
                        Link(destination: catalog.url(forItemOfType: item.type, ref: item.ref, colorId: item.colorId)!) {
                            Text(item.ref)
                        }
                        
                        LegoColorView(orderItem: item, style: .nameOnly)
                    }
                    .font(.caption)
                    
                    Text(item.name)
                        .lineLimit(nil)
                        .font(.title3)
                        .frame(width: 300, alignment: .leading)
                    
                    if !item.comment.isEmpty { Text(item.comment) }
                }
            }
            
            Grid(alignment: .leading) {
                
                GridRow(alignment: .lastTextBaseline) {
                    
                    InventoryLink(inventoryItemId: item.inventoryId) {
                        Text(item.location).font(.title2)
                    }
                    .frame(width: 80, alignment: .leading)
                    
                    Text("x \(item.quantity)").font(.title2)
                        .padding()
                        .background(Color(NSColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1)))
                        .clipShape(Circle())
                    
                    HStack(spacing: 0) {
                        let (_, left) = inventoryStore.inStockQuantityBeforeAfter(for: item)
                        Text("leaves ")
                        Text("\(left)").foregroundStyle(left == 0 ? .red.opacity(0.7) : .secondary)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            switch button {
            case .pick: Button("􀈥 Pick") { pickingStore.pick(item) }
            case .unpick: Button("􀈧 Unpick") { pickingStore.unpick(item) }
            case .verify: Button("􀁢 Verify") { pickingStore.verify(item) }
            case .unverify: Button("􁜢 Unverify") { pickingStore.unverify(item) }
            }
        }
        .padding()
    }
}



enum ButtonType {
    
    case pick
    case unpick
    case verify
    case unverify
}



#Preview(traits: .env) {
    
    PickingItemView(.previewItem1, button: .pick)
}
