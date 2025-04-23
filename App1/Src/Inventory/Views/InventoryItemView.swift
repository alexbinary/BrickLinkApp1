
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
                    if let loc = Location(from: item.remarks) {
                        Text(loc.description).font(.title2)
                    } else {
                        Text(item.remarks).foregroundStyle(.red)
                    }
                    
                    TextField("Remarks", text: $editRemarks)
                        .onSubmit { self.updateInventoryItem(remarks: editRemarks) }
                    Text("􀇿").foregroundStyle(.orange)
                        .opacity(editedRemarks.isInvalid ? 1 : 0)
                    
                    Button("Reset") { editRemarks = item.remarks }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                    Text("\(item.quantity)").font(.title2)
                    
                    TextField("Change quantity +/-", text: $editQty)
                        .onSubmit {
                            if let qty = editedQty.validatedValue {
                                self.updateInventoryItem(addQuantity: qty)
                            }
                        }
                    Text("􀇿").foregroundStyle(.orange)
                        .opacity(editedQty.isInvalid ? 1 : 0)
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Unit price").foregroundStyle(.secondary)
                    Text(item.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                    
                    TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                        .onSubmit {
                            if let price = editedUnitPrice.validatedValue {
                                self.updateInventoryItem(unitPrice: price)
                            }
                        }
                    Text("􀇿").foregroundStyle(.orange)
                        .opacity(editedUnitPrice.isInvalid ? 1 : 0)
                    
                    Button("Reset") { editUnitPrice = item.unitPrice }
                }
            }
            
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
    
    
    var editedRemarks: ValidatedValue<String, Location> {
        
        if let location = Location(from: editRemarks) {
            .valid(rawValue: editRemarks, validatedValue: location)
        } else {
            .invalid(rawValue: editRemarks)
        }
    }
    
    
    var editedQty: ValidatedValue<String, Int> {
        
        if let qty = Int(editQty) {
            .valid(rawValue: editQty, validatedValue: qty)
        } else {
            .invalid(rawValue: editQty)
        }
    }
    
    var editedUnitPrice: ValidatedValue<Float?, Float> {
        
        if let price = editUnitPrice, price > 0 {
            .valid(rawValue: editUnitPrice, validatedValue: price)
        } else {
            .invalid(rawValue: editUnitPrice)
        }
    }
    
    
    func updateInventoryItem(remarks: String? = nil, addQuantity: Int = 0, unitPrice: Float? = nil) {
        
        Task {
            await inventoryStore.updateInventory(inventoryId: item.id, addQuantity: addQuantity, unitPrice: unitPrice, remarks: remarks)
        }
    }
}



enum ValidatedValue<Raw: Equatable, Transformed: Equatable> : Equatable {
    
    case valid(rawValue: Raw, validatedValue: Transformed)
    case invalid(rawValue: Raw)
    
    var isValid: Bool {
        switch self {
        case .invalid: false
        case .valid: true
        }
    }
    var isInvalid: Bool { !isValid }
    
    var validatedValue: Transformed? {
        switch self {
        case .valid(rawValue: _, validatedValue: let value): value
        case .invalid: nil
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
