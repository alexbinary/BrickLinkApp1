
import SwiftUI



struct UploadAddFormView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    
    @State var editingValue_type: ItemType = .part
    @State var editingValue_ref: String = ""
    @State var editingValue_name: String? = nil
    @State var editingValue_colorId: LegoColor.ID? = "1"
    @State var editingValue_quantity: Int = 1
    @State var editingValue_condition: ItemCondition = .used
    @State var editingValue_comment: String = ""
    @State var editingValue_unitPrice: Float = 0
    
    @State var catalogLoading: Bool = false
    @State var catalogResult: CatalogResult? = nil
    @State var isSubmitting = false
    
    
    var body: some View {
            
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Add item")
                Spacer()
                Text("􁚛")
            }
            .font(.title2)
            
            HStack(alignment: .top, spacing: 16) {
                
                Grid(alignment: .leading) {
                    
                    GridRow {
                        
                        Text("Type")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_type.isInvalid ? .red : .secondary
                            )
                        
                        ItemTypePicker("Type", selection: $editingValue_type)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Ref")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_ref.isInvalid ? .red : .secondary
                            )
                        
                        TextField("Ref", text: $editingValue_ref)
                    }
                    
                    GridRow {
                        
                        Text("Name")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_name.isInvalid ? .red : .secondary
                            )
                        
                        HStack {
                            
                            Group {
                                
                                if catalogLoading {
                                    
                                    HStack {
                                        Text("checking catalog...")
                                            .italic()
                                        ProgressView().controlSize(.mini)
                                    }
                                    .foregroundStyle(.secondary)
                                    
                                } else if let catalogResult = catalogResult {
                                    
                                    switch catalogResult {
                                        
                                    case .notFound:
                                        Text("􀁑 invalid type/ref: no catalog entry")
                                            .foregroundStyle(.red)
                                            .italic()
                                        
                                    case .found(let catalogEntry):
                                        Text(catalogEntry.name)
                                            .lineLimit(nil)
                                            .font(.title3)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Button("􀊫") { Task { await refreshCatalogEntry() } }
                        }
                    }
                    
                    GridRow {
                        
                        Text("Color")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_colorId.isInvalid ? .red : .secondary
                            )
                        
                        LegoColorPicker("Color", selection: $editingValue_colorId)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Condition")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_condition.isInvalid ? .red : .secondary
                            )
                        
                        ItemConditionPicker("Condition", selection: $editingValue_condition)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Comment")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_comment.isInvalid ? .red : .secondary
                            )
                        
                        TextField("Comment", text: $editingValue_comment)
                    }
                    
                    Divider()
                    
                    GridRow {
                        
                        Text("Quantity")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_quantity.isInvalid ? .red : .secondary
                            )
                        
                        HStack {
                            TextField("Qty", value: $editingValue_quantity, format: .number)
                            
                            Button {
                                editingValue_quantity = editingValue_quantity + 1
                            } label: {
                                Text("􀅼")
                            }
                            
                            Button {
                                editingValue_quantity = max(1, editingValue_quantity - 1)
                            } label: {
                                Text("􀅽")
                            }
                            .disabled(editingValue_quantity <= 1)
                        }
                    }
                    
                    GridRow {
                        
                        Text("Unit price")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(
                                validatedValue_unitPrice.isInvalid ? .red : .secondary
                            )
                        
                        TextField("Price", value: $editingValue_unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                    }
                    
                    GridRow {
                        
                        Color.clear.frame(width: 0, height: 0)
                        
                        Button("Add") {
                            addItem()
                        }
                            .disabled(!canAdd)
                    }
                }
                
                VStack {
                    
                    CatalogImage(
                        itemType: editingValue_type,
                        ref: editingValue_ref,
                        colorId: editingValue_colorId ?? "",
                        scale: 1.5
                    )
                    .border(validatedValue_condition.submitValue?.color ?? .black, width: 2)
                    
                    if let condition = validatedValue_condition.submitValue {
                        Text(condition.name.uppercased())
                            .font(.title3)
                            .foregroundStyle(condition.color)
                            .fontWeight(.bold)
                    }
                }
            }
        }
        .padding()
        
        .onChange(of: editingValue_type, initial: false) {
            
            catalogResult = nil
            Task { await refreshCatalogEntry() }
        }
        .onChange(of: editingValue_ref, initial: false) {
            
            catalogResult = nil
            Task { await refreshCatalogEntry() }
        }
    }
    
    
    var validatedValue_type: ValidatedValue<ItemType> {
        
        .init(
            submitValue: editingValue_type, validity: .valid
        )
    }
    
    var validatedValue_ref: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.ref,
            validity: catalogLoading ? .indeterminate : .valid
        )
        default: .init(
            
            submitValue: editingValue_ref,
            validity: (catalogResult == nil || catalogLoading) ? .indeterminate : .invalid
        )
        }
    }
    
    var validatedValue_name: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.name,
            validity: catalogLoading ? .indeterminate : .valid
        )
        default: .init(
            
            submitValue: nil,
            validity: (catalogResult == nil || catalogLoading) ? .indeterminate : .invalid
        )
        }
    }
    
    var validatedValue_colorId: ValidatedValue<LegoColor.ID> {
        
        if let colorId = editingValue_colorId {
            
            return .init(
                submitValue: colorId, validity: .valid
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid
            )
        }
    }
    
    var validatedValue_condition: ValidatedValue<ItemCondition> {
        
        .init(
            submitValue: editingValue_condition, validity: .valid
        )
    }
    
    var validatedValue_comment: ValidatedValue<String> {
        
        .init(
            submitValue: editingValue_comment, validity: .valid
        )
    }
    
    var validatedValue_quantity: ValidatedValue<Int> {
        
        if editingValue_quantity > 0 {
        
            return .init(
                submitValue: editingValue_quantity, validity: .valid
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid
            )
        }
    }
    
    var validatedValue_unitPrice: ValidatedValue<Float> {
        
        if editingValue_unitPrice > 0 {
        
            return .init(
                submitValue: editingValue_unitPrice, validity: .valid
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid
            )
        }
    }
    
    
    func refreshCatalogEntry() async {
        
        guard let type = validatedValue_type.submitValue,
              let ref = validatedValue_ref.submitValue
        else {
            return
        }
        
        catalogLoading = true
        
        if let catalogEntry = await catalog.fetchEntry(forItemType: type, ref: ref) {
            
            catalogResult = .found(catalogEntry)
        } else {
            catalogResult = .notFound
        }
        
        catalogLoading = false
    }
    
    
    var canAdd: Bool {

        if isSubmitting { return false }
        
        return
            validatedValue_type.isValid
            &&
            validatedValue_ref.isValid
            &&
            validatedValue_colorId.isValid
            &&
            validatedValue_condition.isValid
            &&
            validatedValue_comment.isValid
            &&
            validatedValue_quantity.isValid
            &&
            validatedValue_unitPrice.isValid
    }
    
    
    func addItem() {
        
        uploadStore.add(UploadItem(
            type: validatedValue_type.submitValue!,
            ref: validatedValue_ref.submitValue!,
            name: validatedValue_name.submitValue,
            colorId: validatedValue_colorId.submitValue,
            qty: validatedValue_quantity.submitValue,
            condition: validatedValue_condition.submitValue,
            comment: validatedValue_comment.submitValue,
            unitPrice: validatedValue_unitPrice.submitValue
        ))
    }
}
