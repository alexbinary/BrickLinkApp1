
import SwiftUI



struct PickingItemView: View {
    
    
    @Environment(PickingStore.self)
    var pickingStore
    
    @Environment(StockController.self)
    var stockController
    
    
    let item: OrderItem
    let button: ButtonType
    
    init(_ item: OrderItem, button: ButtonType) {
        self.item = item
        self.button = button
    }
        
    
    var body: some View {
        
        HStack(spacing: 48) {
                
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    CatalogImage(orderItem: item)
                    
                    VStack(alignment: .leading) {
                        Text(item.ref).captionStyle()
                        Text(item.name).lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading)
                        if !item.comment.isEmpty { Text(item.comment) }
                    }
                }
                
                GridRow {
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    LegoColorView(orderItem: item).gridColumnAlignment(.leading)
                }
            }
            
            Grid(alignment: .leading) {
                
                GridRow {
                    Text("Location").captionStyle()
                    Text("Quantity").captionStyle().gridColumnAlignment(.center)
                }
                
                GridRow(alignment: .lastTextBaseline) {
                    Text(item.location).font(.title2).frame(width: 80, alignment: .leading)
                    Text(item.quantity).font(.title2)
                    
                    HStack(spacing: 0) {
                        let (before, after) = stockController.inStockQuantityBeforeAfter(for: item)
                        Text("(\(before) 􁉂 ")
                        Text("\(after)").foregroundStyle(after == 0 ? .red.opacity(0.7) : .secondary)
                        Text(")")
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            switch button {
            case .pick: Button("Pick") { pickingStore.pick(item) }
            case .unpick: Button("Unpick") { pickingStore.unpick(item) }
            case .verify: Button("Verify") { pickingStore.verify(item) }
            case .unverify: Button("Unverify") { pickingStore.unverify(item) }
            }
        }
        .padding()
        .roundedContainer(fill: .secondarySystemFill, stroke: .tertiarySystemFill)
    }
}



enum ButtonType {
    
    case pick
    case unpick
    case verify
    case unverify
}



#Preview {
    
    let appController = AppController()
    let orderStore = appController.orderStore
    let pickingStore = appController.pickingStore
    let stockController = appController.stockController
    
    let order = orderStore.orderSummaries.first!
    let item = orderStore.orderItems(forOrderWithId: order.id).first!
    
    PickingItemView(item, button: .pick)
        .environment(pickingStore)
        .environment(stockController)
}
