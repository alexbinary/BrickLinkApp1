
import SwiftUI



struct UploadAddItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    
    let uploadItem: UploadItem
    
    init(uploadItem: UploadItem) {
        
        self.uploadItem = uploadItem
        self._editColorId = State(initialValue: uploadItem.colorId)
    }
    
    
    @State var hover = false
    @State var catalogResult: Result<CatalogEntry>? = nil
    
    @State var editModeRef = false
    @State var editModeColor = false
    @State var editModeCondition = false
    @State var editModeComment = false
    @State var editModeQty = false
    @State var editModePrice = false
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID
    @State var editCondition: ItemCondition?
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?

    
    var body: some View {
        
        HStack(alignment: .center) {
        
            HStack(alignment: .top) {
                
                Grid(verticalSpacing: 0) {
                    
                    GridRow(alignment: .top) {
                        
                        CatalogImage(uploadItem: uploadItem)
                            .border(conditionColor, width: 2)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            HStack {
                                
                                ZStack(alignment: .leading) {
                                    
                                    Text(uploadItem.ref)
                                        .onTapGesture { editModeRef = true }
                                        .captionStyle()
                                        .opacity(editModeRef ? 0 : 1)
                                    
                                    TextField("Ref", text: $editRef)
                                        .frame(maxWidth: 100)
                                        .onSubmit({
                                            if editRef.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                                editRef = uploadItem.ref
                                            }
                                            editModeRef = false
                                        })
                                        .opacity(editModeRef ? 1 : 0)
                                }
                                
                                ZStack(alignment: .leading) {
                                    
                                    Text(catalog.colorName(forLegoColorId: uploadItem.colorId))
                                        .onTapGesture { editModeColor = true }
                                        .opacity(editModeColor ? 0 : 1)
                                    
                                    LegoColorPicker("Color", selection: $editColorId)
                                        .labelsHidden()
                                        .frame(maxWidth: 150)
                                        .onChange(of: editColorId, {
                                            editModeColor = false
                                        })
                                        .opacity(editModeColor ? 1 : 0)
                                }
                            }
                            
                            Group {
                                
                                if let catalogResult = catalogResult {
                                    
                                    switch catalogResult {
                                        
                                    case .loading:
                                        Text("Loading name from catalog...").foregroundStyle(.secondary)
                                        
                                    case .found(let catalogEntry):
                                        Text(catalogEntry.name).lineLimit(nil)
                                        
                                    case .notFound:
                                        Text("no catalog entry").foregroundStyle(.secondary)
                                    }
                                    
                                } else if let name = uploadItem.name {
                                    
                                    Text(name).lineLimit(nil)
                                    
                                } else {
                                    
                                    Text("name unknown").foregroundStyle(.secondary).italic()
                                }
                            }
                            .font(.title3).frame(width: 300, alignment: .leading)
                            
                            ZStack(alignment: .leading) {
                                
                                Group {
                                    if !(uploadItem.comment ?? "").isEmpty {
                                        Text((uploadItem.comment ?? "").htmlUnescape())
                                    } else {
                                        Text("no comment").italic().foregroundStyle(.secondary)
                                    }
                                }
                                .onTapGesture { editModeComment = true }
                                .opacity(editModeComment ? 0 : 1)
                                
                                TextField("Comment", text: $editComment)
                                    .frame(maxWidth: 200)
                                    .onSubmit { editModeComment = false }
                                    .opacity(editModeComment ? 1 : 0)
                            }
                        }
                    }
                    
                    GridRow {
                        
                        ZStack {
                            
                            Text(uploadItem.condition?.name.uppercased() ?? "-")
                                .font(.title3)
                                .foregroundStyle(conditionColor)
                                .fontWeight(.bold)
                                .onTapGesture { editModeCondition = true }
                                .opacity(editModeCondition ? 0 : 1)
                            
                            Picker("Condition", selection: $editCondition) {
                                
                                Text("").tag(nil as ItemCondition?)
                                Text("NEW").tag(ItemCondition.new)
                                Text("USED").tag(ItemCondition.used)
                            }
                            .labelsHidden()
                            .frame(maxWidth: 90)
                            .onChange(of: editCondition) {
                                editModeCondition = false
                            }
                            .opacity(editModeCondition ? 1 : 0)
                            
                        }.gridColumnAlignment(.center)
                    }
                }
                
                Grid(alignment: .leading, verticalSpacing: 8) {
                    
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                        
                        if !editModeQty {
                            
                            HStack {
                                
                                Group {
                                    if let qty = uploadItem.qty {
                                        Text("+\(qty)")
                                    } else {
                                        Text("-")
                                    }
                                }
                                .font(.title2)
                                .onTapGesture {
                                    editModeQty = true
                                }
                                
                                Button {
                                    updateItem(qty: (uploadItem.qty ?? 0) + 1)
                                } label: {
                                    Text("􁾨")
                                }
                                
                                Button {
                                    updateItem(qty: (uploadItem.qty ?? 0) - 1)
                                } label: {
                                    Text("􁾬")
                                }
                            }
                            
                        } else {
                            
                            TextField("Qty", value: $editQty, format: .number).multilineTextAlignment(.center)
                                .frame(maxWidth: 50)
                                .onSubmit({
                                    editModeQty = false
                                })
                        }
                    }
                    
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Unit price").foregroundStyle(.secondary)
                        
                        ZStack(alignment: .leading) {
                            
                            Group {
                                if let price = uploadItem.unitPrice {
                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).monospacedDigit()
                                } else {
                                    Text("-")
                                }
                            }
                            .font(.title2)
                            .onTapGesture {
                                editModePrice = true
                            }
                            .opacity(editModePrice ? 0 : 1)
                            
                            TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                .onSubmit({
                                    editModePrice = false
                                })
                                .frame(maxWidth: 100)
                                .opacity(editModePrice ? 1 : 0)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button {
                uploadStore.delete(uploadItem)
            } label: {
                Text("􀈑 Delete")
            }
            .fixedSize()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .roundedContainer(
            fill: hover ? .secondarySystemFill : .tertiarySystemFill,
            stroke: .tertiarySystemFill
        )
        .onHover { self.hover = $0 }
        
        .onChange(of: editModeRef) { old, new in
            if new == true {
                editRef = uploadItem.ref
            }
        }
        .onChange(of: editModeColor) { old, new in
            if new == true {
                editColorId = uploadItem.colorId
            }
        }
        .onChange(of: editModeCondition) { old, new in
            if new == true {
                editCondition = uploadItem.condition
            }
        }
        .onChange(of: editModeComment) { old, new in
            if new == true {
                editComment = uploadItem.comment ?? ""
            }
        }
        .onChange(of: editModeQty) { old, new in
            if new == true {
                editQty = uploadItem.qty
            }
        }
        .onChange(of: editModePrice) { old, new in
            if new == true {
                editUnitPrice = uploadItem.unitPrice
            }
        }
        
        .onChange(of: editModeRef) { old, new in
            if new == false, editRef != uploadItem.ref {
                updateItem(ref: editRef)
            }
        }
        .onChange(of: editModeColor) { old, new in
            if new == false, editColorId != uploadItem.colorId {
                updateItem(colorId: editColorId)
            }
        }
        .onChange(of: editModeCondition) { old, new in
            if new == false, editCondition != uploadItem.condition {
                updateItem(condition: editCondition)
            }
        }
        .onChange(of: editModeComment) { old, new in
            if new == false, editComment.trimmingCharacters(in: .whitespacesAndNewlines) != (uploadItem.comment ?? "").trimmingCharacters(in: .whitespacesAndNewlines) {
                updateItem(comment: editComment)
            }
        }
        .onChange(of: editModeQty) { old, new in
            if new == false, editQty != uploadItem.qty {
                updateItem(qty: editQty)
            }
        }
        .onChange(of: editModePrice) { old, new in
            if new == false, editUnitPrice != uploadItem.unitPrice {
                updateItem(unitPrice: editUnitPrice)
            }
        }
        
        .onChange(of: uploadItem.ref, initial: false) {
            uploadStore.update(UploadItem(
                
                id: uploadItem.id,
                type: uploadItem.type,
                ref: uploadItem.ref,
                name: nil,
                colorId: uploadItem.colorId,
                qty: uploadItem.qty,
                condition: uploadItem.condition,
                comment: uploadItem.comment,
                unitPrice: uploadItem.unitPrice
            ))
        }
        .onChange(of: uploadItem.name, initial: true) { old, new in
            if new == nil {
                Task { await pullCatalogEntry() }
            }
        }
    }
    
    
    func updateItem(
        
        ref: String? = nil,
        name: String? = nil,
        colorId: String? = nil,
        qty: Int? = nil,
        condition: ItemCondition? = nil,
        comment: String? = nil,
        unitPrice: Float? = nil
    
    ) {
        
        uploadStore.update(UploadItem(
            
            id: uploadItem.id,
            type: uploadItem.type,
            ref: ref ?? uploadItem.ref,
            name: name ?? uploadItem.name,
            colorId: colorId ?? uploadItem.colorId,
            qty: qty ?? uploadItem.qty,
            condition: condition ?? uploadItem.condition,
            comment: comment ?? uploadItem.comment,
            unitPrice: unitPrice ?? uploadItem.unitPrice
        ))
    }
    
    
    func pullCatalogEntry() async {
        
        self.catalogResult = .loading
        
        if let catalogEntry = await catalog.fetchEntry(forItemType: uploadItem.type, ref: uploadItem.ref) {
            
            self.catalogResult = .found(catalogEntry)
            updateItem(name: catalogEntry.name)
        } else {
            self.catalogResult = .notFound
        }
    }
    
    
    var conditionColor: Color {
        switch uploadItem.condition {
        case .used: return .red
        case .new: return .blue
        default: return .clear
        }
    }
}
