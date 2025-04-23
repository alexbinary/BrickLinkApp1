
import SwiftUI



struct InventoryItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let item: InventoryItem
    
    
    @State var hover = false
    
    
    var body: some View {
        
        HStack(spacing: 48) {
                
            HStack(alignment: .top) {

                VStack(spacing: 0) {

                    CatalogImage(inventoryItem: item)
                        .border(conditionColor, width: 2)
                    
                    Text(item.condition == "U" ? "USED" : "NEW")
                        .font(.title3)
                        .foregroundStyle(conditionColor)
                        .fontWeight(.bold)
                    
                    InventoryLink(inventoryItemId: item.id) {
                        Text("\(item.id)")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        
                        Link(destination: catalog.url(forItemOfType: item.type, ref: item.ref, colorId: item.colorId)!) {
                            Text(item.ref)
                        }
                        
                        LegoColorView(inventoryItem: item, style: .nameOnly)
                    }
                    .font(.caption)
                    
                    Text(item.name)
                        .lineLimit(nil)
                        .font(.title3)
                        .frame(width: 300, alignment: .leading)
                    
                    if !item.description.isEmpty { Text(item.description) }
                }
            }
            
            Grid(alignment: .leading, verticalSpacing: 12) {
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Remarks").foregroundStyle(.secondary)
                    Text(item.remarks).font(.title2)
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                    Text("\(item.quantity)").font(.title2)
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    Text("Unit price").foregroundStyle(.secondary)
                    Text(item.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .roundedContainer(
            fill: hover ? .secondarySystemFill : .tertiarySystemFill,
            stroke: .tertiarySystemFill
        )
        .onHover { self.hover = $0 }
    }
    
    
    var conditionColor: Color {
        switch item.condition {
        case "U": return .red
        case "N": return .blue
        default: return .clear
        }
    }
}



#Preview {
    
    VStack {
        
        InventoryItemView(item: .init(
            id: "1234567890",
            condition: "N",
            colorId: "11",
            ref: "3001",
            name: "Preview name",
            type: .part,
            description: "description",
            remarks: "A1-2.3",
            quantity: 1,
            unitPrice: 2.3456
        ))
        .padding()
        .previewEnv(
            catalog: PreviewCatalog(
                urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
            )
        )
        
        InventoryItemView(item: .init(
            id: "1",
            condition: "U",
            colorId: "",
            ref: "",
            name: "",
            type: .part,
            description: "",
            remarks: "",
            quantity: 0,
            unitPrice: 0
        ))
        .padding()
        .previewEnv(
            catalog: PreviewCatalog(
                urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
            )
        )
    }
}
