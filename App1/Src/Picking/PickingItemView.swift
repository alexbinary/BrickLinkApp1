
import SwiftUI



struct PickingItemView: View {
    
    
    @EnvironmentObject
    var app: AppController
    
    
    let item: OrderItem
    let buttons: [ButtonType]
    
    init(_ item: OrderItem, buttons: [ButtonType]) {
        self.item = item
        self.buttons = buttons
    }
        
    
    var body: some View {
        
        HStack(spacing: 48) {
                
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    AsyncImage(url: app.url(for: item))
                        .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                        .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                    
                    VStack(alignment: .leading) {
                        Text(item.ref).font(.caption).foregroundStyle(.secondary)
                        Text(item.name.htmlUnescape()).lineLimit(nil).font(.title3).frame(width: 300, alignment: .leading)
                        if !item.comment.isEmpty {
                            Text(item.comment.htmlUnescape())
                        }
                    }
                }
                
                GridRow {
                
                    Text(item.condition == "U" ? "USED" : "NEW").font(.title3).gridColumnAlignment(.center)
                    HStack {
                        app.color(for: item).frame(width: 18, height: 18)
                        Text(app.colorName(for: item))
                    }.gridColumnAlignment(.leading)
                }
            }
            
            let itemIsPicked = app.pickedItems(forOrderWithId: item.orderId).contains(item.id)
            
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
                
                ForEach(buttons, id: \.self) { button in
                    switch button {
                    case .pick:
                        Button {
                            app.pickItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Pick")
                        }
                    case .unpick:
                        Button {
                            app.unpickItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Unpick")
                        }
                    case .verify:
                        Button {
                            app.verifyItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Verify")
                        }
                    case .unverify:
                        Button {
                            app.unverifyItem(forOrderWithId: item.orderId, item: item.id)
                        } label: {
                            Text("Unverify")
                        }
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
    PickingItemView(item, buttons: [.pick]).environmentObject(appController)
}
