
import SwiftUI



struct InventoryItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let item: InventoryItem
    
    
    @State var hover = false
    
    @State var editingValue_remarks: String = ""
    @State var editingValue_quantity: String = ""
    @State var editingValue_unitPrice: Float? = nil
    
    @Binding var listSearchText: String
    @Binding var listSearchTokens: [SearchToken]
    
    
    var body: some View {
        
        HStack(spacing: 48) {
                
            HStack(alignment: .top) {

                VStack(spacing: 0) {

                    CatalogImage(inventoryItem: item)
                        .border(item.condition.color, width: 2)
                    
                    Text(item.condition.name.uppercased())
                        .font(.title3)
                        .foregroundStyle(item.condition.color)
                        .fontWeight(.bold)
                    
                    InventoryLink(inventoryItemId: item.id) {
                        Text("\(item.id)")
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {

                    HStack {
                        
                        Button("􀭥") {
                            listSearchTokens = [.refIs(item.ref)]
                            listSearchText = ""
                        }
                        
                        Link(destination: catalog.url(forItemOfType: item.type, ref: item.ref, colorId: item.colorId)!) {
                            Text(item.ref)
                        }
                        
                        LegoColorView(inventoryItem: item, style: .nameOnly)
                    }
                    .font(.caption)
                    
                    Text(item.name.htmlUnescape())
                        .lineLimit(nil)
                        .font(.title3)
                        .frame(width: 300, alignment: .leading)
                    
                    if !item.description.isEmpty {
                        Text(item.description)
                            .lineLimit(nil)
                            .frame(width: 300, alignment: .leading)
                    }
                }
            }
            
            Grid(alignment: .leading, verticalSpacing: 12) {
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Remarks")
                        .foregroundStyle(
                            validatedValue_remarks.isInvalid ? .red
                            : validatedValue_remarks.hasChanges ? .blue
                            : .secondary
                        )
                        .italic(validatedValue_remarks.hasChanges)
                        
                    HStack {
                        TextField("Remarks", text: $editingValue_remarks)
                            .onSubmit {
                                updateRemarks()
                                reset()
                            }
                        
                        if validatedValue_remarks.hasChanges {
                            Button("􀅉") { editingValue_remarks = item.remarks }
                        }
                    }
                    
                    Button("􀭥") {
                        if let loc = Location(from: item.remarks) {
                            listSearchTokens = [.locationIs(loc)]
                            listSearchText = ""
                        } else {
                            listSearchTokens = []
                            listSearchText = item.remarks
                        }
                    }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Quantity").gridColumnAlignment(.trailing)
                        .foregroundStyle(
                            validatedValue_quantity.isInvalid ? .red
                            : validatedValue_quantity.hasChanges ? .blue
                            : .secondary
                        )
                        .italic(validatedValue_quantity.hasChanges)
                    
                    HStack {
                        Text("\(item.quantity)").font(.title2)
                        
                        TextField("Change quantity +/-", text: $editingValue_quantity)
                            .onSubmit {
                                updateQuantity()
                                reset()
                            }
                        
                        if validatedValue_quantity.hasChanges {
                            Button("􀅉") { editingValue_quantity = "" }
                        }
                    }
                }
                
                GridRow(alignment: .firstTextBaseline) {
                    
                    Text("Unit price")
                        .foregroundStyle(
                            validatedValue_unitPrice.isInvalid ? .red
                            : validatedValue_unitPrice.hasChanges ? .blue
                            : .secondary
                        )
                        .italic(validatedValue_unitPrice.hasChanges)
                    
                    HStack {
                        TextField("Price", value: $editingValue_unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                            .onSubmit {
                                updatePrice()
                                reset()
                            }
                        
                        if validatedValue_unitPrice.hasChanges {
                            Button("􀅉") { editingValue_unitPrice = item.unitPrice }
                        }
                    }
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
            reset()
        }
    }
    
    
    var validatedValue_remarks: ValidatedValue<String> {
        
        if let loc = Location(from: editingValue_remarks) {
            .init(
                submitValue: loc.textRepresentation, validity: .valid,
                hasChanges: loc.textRepresentation != savedValue_remarks
            )
        } else {
            .init(
                submitValue: editingValue_remarks, validity: .invalid,
                hasChanges: editingValue_remarks != savedValue_remarks
            )
        }
    }
    
    
    var validatedValue_quantity: ValidatedValue<Int> {
        
        if let qty = Int(editingValue_quantity) {
            .init(
                submitValue: qty, validity: .valid,
                hasChanges: true
            )
        } else if editingValue_quantity.isEmpty {
            .init(
                submitValue: nil, validity: .valid
            )
        } else {
            .init(
                submitValue: nil, validity: .invalid,
                hasChanges: true
            )
        }
    }
    
    
    var validatedValue_unitPrice: ValidatedValue<Float> {
        
        if let price = editingValue_unitPrice, price > 0 {
            .init(
                submitValue: price, validity: .valid,
                hasChanges: price != savedValue_unitPrice
            )
        } else {
            .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_unitPrice != savedValue_unitPrice
            )
        }
    }
    
    
    var savedValue_remarks: String { item.remarks }
    var savedValue_quantity: Int { item.quantity }
    var savedValue_unitPrice: Float { item.unitPrice }
    
    
    func updateRemarks() {
        
        if let rem = validatedValue_remarks.submitValue {
            self.updateInventoryItem(remarks: rem)
        }
    }
    
    
    func updateQuantity() {
        
        if let qty = validatedValue_quantity.submitValue {
            self.updateInventoryItem(addQuantity: qty)
        }
    }
    
    
    func updatePrice() {
     
        if let price = validatedValue_unitPrice.submitValue {
            self.updateInventoryItem(unitPrice: price)
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
    
    
    func reset() {
        
        self.editingValue_remarks = item.remarks
        self.editingValue_quantity = ""
        self.editingValue_unitPrice = item.unitPrice
    }
}



#Preview {
    
    VStack {
        
        InventoryItemView(item: .init(
            id: "1234567890",
            condition: .new,
            colorId: "11",
            ref: "3001",
            name: "Preview name",
            type: .part,
            description: "description",
            remarks: "A1-2.3",
            quantity: 1,
            unitPrice: 2.3456
        ), listSearchText: .constant(""), listSearchTokens: .constant([]))
        .padding()
        .previewEnv(
            catalog: PreviewCatalog(
                urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
            )
        )
        
        InventoryItemView(item: .init(
            id: "1",
            condition: .used,
            colorId: "",
            ref: "",
            name: "",
            type: .part,
            description: "",
            remarks: "",
            quantity: 0,
            unitPrice: 0
        ), listSearchText: .constant(""), listSearchTokens: .constant([]))
        .padding()
        .previewEnv(
            catalog: PreviewCatalog(
                urlForImageOfItemOfType: URL(string: "https://img.bricklink.com/P/11/3001.jpg"),
            )
        )
    }
}
