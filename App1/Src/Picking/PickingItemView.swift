
import SwiftUI



struct PickingItemView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
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
                        Text(item.ref).font(.caption).foregroundStyle(.secondary)
                        Text(item.name).lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading)
                        if !item.comment.isEmpty { Text(item.comment) }
                    }
                }
                
                GridRow {
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    LegoColorView(orderItem: item).gridColumnAlignment(.leading)
                }
            }
            
            let itemIsPicked = app.pickedItemIds(forOrderWithId: item.orderId).contains(item.id)
            
            Grid(alignment: .leading) {
                
                GridRow {
                    Text("Location").font(.caption).foregroundStyle(.secondary)
                    Text("Quantity").font(.caption).foregroundStyle(.secondary)
                        .gridColumnAlignment(.center)
                }
                
                GridRow(alignment: .lastTextBaseline) {
                    Text(item.location).font(.title2).frame(width: 80, alignment: .leading)
                    Text(item.quantity).font(.title2)
                    HStack(spacing: 0) {
                        let stock = app.inStockQuantity(for: item)
                        let qty = Int(item.quantity)!
                        let (before, after) = {
                            if !itemIsPicked {
                                return (stock, stock - qty)
                            } else {
                                return (stock + qty, stock)
                            }
                        }()
                        Text("(\(before) 􁉂 ")
                        Text(after, format: .number)
                            .foregroundStyle(after == 0 ? .red.opacity(0.7) : .secondary)
                        Text(")")
                    }
                    .foregroundStyle(.secondary)
                
                }
            }
            
            Spacer()
            
            VStack (alignment: .leading) {
                
                switch button {
                case .pick:
                    Button("Pick") {
                        app.pickItem(forOrderWithId: item.orderId, itemId: item.id)
                    }
                case .unpick:
                    Button("Unpick") {
                        app.unpickItem(forOrderWithId: item.orderId, itemId: item.id)
                    }
                case .verify:
                    Button("Verify") {
                        app.verifyItem(forOrderWithId: item.orderId, itemId: item.id)
                    }
                case .unverify:
                    Button("Unverify") {
                        app.unverifyItem(forOrderWithId: item.orderId, itemId: item.id)
                    }
                }
            }
        }
        .padding()
        .roundedContainer(
            backgroundColor: .secondarySystemFill,
            borderColor: .tertiarySystemFill
        )
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
    let order = appController.orderSummaries.first!
    let item = appController.orderItems(forOrderWithId: order.id).first!
    PickingItemView(item, button: .pick).environmentObject(appController)
}
