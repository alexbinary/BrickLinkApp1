
import SwiftUI



struct UploadItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let uploadItem: UploadItem
    
    
    @State var hover = false
    @State var catalogResult: Result<CatalogEntry>? = nil
    
    
    var body: some View {
        
        HStack(spacing: 48) {
            
            HStack(alignment: .top) {
                
                VStack(spacing: 0) {
                    
                    CatalogImage(uploadItem: uploadItem)
                        .border(uploadItem.condition?.color ?? .black, width: 2)
                    
                    if let condition = uploadItem.condition {
                        Text(condition.name.uppercased())
                            .font(.title3)
                            .foregroundStyle(condition.color)
                            .fontWeight(.bold)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        
                        Link(destination: catalog.url(forItemOfType: uploadItem.type, ref: uploadItem.ref, colorId: uploadItem.colorId)!) {
                            Text(uploadItem.ref)
                        }
                        .font(.caption)
                        
                        if let colorId = uploadItem.colorId {
                            LegoColorView(colorId: colorId, style: .nameOnly)
                                .font(.caption)
                        }
                    }
                    
                    if let name = uploadItem.name {
                        Text(name)
                            .lineLimit(nil)
                            .font(.title3)
                    }
                    
                    if !(uploadItem.comment ?? "").isEmpty {
                        Text((uploadItem.comment ?? "").htmlUnescape())
                    }
                }
            }
            .frame(width: 300, alignment: .leading)
               
            Grid(alignment: .leading, verticalSpacing: 8) {
                    
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Quantity")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                        
                    if let qty = uploadItem.qty {
                        Text("+\(qty)")
                            .font(.title2)
                    }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Unit price")
                        .foregroundStyle(.secondary)
                        .gridColumnAlignment(.trailing)
                    
                    if let price = uploadItem.unitPrice {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                            .monospacedDigit()
                            .font(.title2)
                    }
                }
            }
            .frame(width: 300, alignment: .leading)
            
            if itemIsValid {
                
                Grid(alignment: .leading, verticalSpacing: 8) {
                    
                    GridRow(alignment: .firstTextBaseline) {
                        
                        Text("Inventory")
                            .foregroundStyle(.secondary)
                            .gridColumnAlignment(.trailing)
                        
                        if let inventoryItem = inventoryItem {
                            InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                        } else {
                            Text("New lot 􀫸")
                        }
                    }
                    
                    if let inventoryItem = inventoryItem {
                        
                        GridRow(alignment: .firstTextBaseline) {
                            
                            Text("Quantity")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                            
                            Text("\(inventoryItem.quantity)")
                        }
                        
                        GridRow(alignment: .firstTextBaseline) {
                            
                            Text("Unit price")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                            
                            Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                .monospacedDigit()
                        }
                        
                        GridRow(alignment: .firstTextBaseline) {
                            
                            Text("Remarks")
                                .foregroundStyle(.secondary)
                                .gridColumnAlignment(.trailing)
                            
                            Text(inventoryItem.remarks)
                        }
                    }
                }
                
            } else {
                
                Text("Invalid item")
                    .foregroundStyle(.secondary)
                    .italic()
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
    
    
    var inventoryItem: InventoryItem? {
        
        return inventoryStore.inventory(for: uploadItem)
    }
    
    
    var itemIsValid: Bool {
        
        return
            !uploadItem.ref.isEmpty
            &&
            !(uploadItem.colorId ?? "").isEmpty
            &&
            uploadItem.condition != nil
    }
}
