
import SwiftUI



struct InventoryItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let item: InventoryItem
    
    
    @State var hover = false
    
    @State var editRemarks: String = ""
    @State var editQty: String = ""
    @State var editUnitPrice: Float? = nil
    
    @Binding var listSearchText: String
    
    
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
                        
                        Button("􀭥") { listSearchText = item.ref }
                        
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
                    
                    Text("Remarks")
                        .foregroundStyle(validatedRemarks.hasWarning ? .red : .secondary)
                        
                    TextField("Remarks", text: $editRemarks)
                        .onSubmit {
                            if let rem = validatedRemarks.valueToSubmit {
                                self.updateInventoryItem(remarks: rem)
                            }
                        }
                    
                    Button("􀅉") { editRemarks = item.remarks }
                    
                    Button("􀭥") { listSearchText = item.remarks }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Quantity").gridColumnAlignment(.trailing)
                        .foregroundStyle(validatedQty.hasWarning ? .red : .secondary)
                    
                    HStack {
                        Text("\(item.quantity)").font(.title2)
                        
                        TextField("Change quantity +/-", text: $editQty)
                            .onSubmit {
                                if let qty = validatedQty.valueToSubmit {
                                    self.updateInventoryItem(addQuantity: qty)
                                }
                            }
                    }
                    
                    Button("􀅉") { editQty = "" }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Unit price")
                        .foregroundStyle(validatedUnitPrice.hasWarning ? .red : .secondary)
                    
                    TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                        .onSubmit {
                            if let price = validatedUnitPrice.valueToSubmit {
                                self.updateInventoryItem(unitPrice: price)
                            }
                        }
                    
                    Button("􀅉") { editUnitPrice = item.unitPrice }
                }
            }
            .frame(width: 300)
            
            if inventoryStore.isUpdatingInventory(withId: item.id) {
                ProgressView().controlSize(.small)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .roundedContainer(
            fill: hover ? .secondarySystemFill : .tertiarySystemFill,
            stroke: .tertiarySystemFill
        )
        .onHover { self.hover = $0 }
        .onChange(of: item, initial: true) {
            self.editRemarks = item.remarks
            self.editUnitPrice = item.unitPrice
        }
    }
    
    
    var conditionColor: Color {
        switch item.condition {
        case "U": return .red
        case "N": return .blue
        default: return .clear
        }
    }
    
    
    var validatedRemarks: ValidatedValue<String> {
        
        if Location(from: editRemarks) == nil {
            .init(valueToSubmit: editRemarks, hasWarning: true)
        } else {
            .init(valueToSubmit: editRemarks, hasWarning: false)
        }
    }
    
    
    var validatedQty: ValidatedValue<Int> {
        
        if let qty = Int(editQty) {
            .init(valueToSubmit: qty, hasWarning: false)
        } else if editQty.isEmpty {
            .init(valueToSubmit: nil, hasWarning: false)
        } else {
            .init(valueToSubmit: nil, hasWarning: true)
        }
    }
    
    
    var validatedUnitPrice: ValidatedValue<Float> {
        
        if let price = editUnitPrice, price > 0 {
            .init(valueToSubmit: price, hasWarning: false)
        } else {
            .init(valueToSubmit: nil, hasWarning: true)
        }
    }
    
    
    func updateInventoryItem(remarks: String? = nil, addQuantity: Int = 0, unitPrice: Float? = nil) {
        
        Task {
            await inventoryStore.updateInventory(
                inventoryId: item.id,
                addQuantity: addQuantity,
                unitPrice: unitPrice,
                remarks: remarks
            )
        }
    }
}



struct ValidatedValue<T> {
    
    var valueToSubmit: T? = nil
    var hasWarning: Bool = false
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
        ), listSearchText: .constant(""))
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
        ), listSearchText: .constant(""))
        .padding()
        .previewEnv(
            catalog: PreviewCatalog(
                urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
            )
        )
    }
}
