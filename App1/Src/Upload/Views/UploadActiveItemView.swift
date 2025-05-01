
import SwiftUI



struct UploadActiveItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let uploadItemId: UploadItem.ID
    var uploadItem: UploadItem { uploadStore.uploadItemsForList.first(where: { $0.id == uploadItemId })! }
    
    
    @State var catalogResult: Result<CatalogEntry>? = nil
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID = ""
    @State var editCondition: String?
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""
    
    @State var submitting = false

    
    var body: some View {
        
        let itemErrors: [String] = {
            
            var errors = [String]()
            
            if uploadItem.ref.normalizedOptional == nil {
                errors.append("invalid item ref")
            }
            
            if uploadItem.condition.normalizedOptional == nil {
                errors.append("missing condition")
            }
            
            return errors
        }()
        
        let itemValid = itemErrors.isEmpty
        
        VStack(alignment: .leading) {
        
            HStack {
                Text("Upload item").font(.title2)
                Text("􁉂􀈫")
            }
        
            HStack(alignment: .top) {
                
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .top, spacing: 16) {
                        
                        VStack {
                            CatalogImage(uploadItem: uploadItem)
                                .border(conditionColor, width: 2)
                         
                            if let condition = uploadItem.condition {
                                Text(condition == "U" ? "USED" : "NEW")
                                    .font(.title3)
                                    .foregroundStyle(conditionColor)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        Grid(alignment: .leading) {
                            
                            GridRow {
                                
                                Text("Ref").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                
                                TextField("Ref", text: $editRef)
                                    .onSubmit({
                                        if editRef.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                            editRef = uploadItem.ref
                                        }
                                        updateItem(ref: editRef)
                                    })
                            }
                            
                            GridRow {
                                
                                Text("Name").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                
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
                                .font(.title3)
                            }
                            
                            GridRow {
                                
                                Text("Color").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                
                                LegoColorPicker("Color", selection: $editColorId)
                                    .labelsHidden()
                                    .onChange(of: editColorId, {
                                        updateItem(colorId: editColorId)
                                    })
                            }
                            
                            GridRow {
                                
                                Text("Condition").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                
                                Picker("Condition", selection: $editCondition) {
                                    
                                    Text("").tag(nil as String?)
                                    Text("NEW")
                                        .foregroundStyle(color(for: "N"))
                                        .fontWeight(.bold)
                                        .tag("N")
                                    Text("USED")
                                        .foregroundStyle(color(for: "U"))
                                        .fontWeight(.bold)
                                        .tag("U")
                                }
                                .labelsHidden()
                                .onChange(of: editCondition) {
                                    updateItem(condition: editCondition)
                                }
                            }
                            
                            GridRow {
                                
                                Text("Comment").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                             
                                TextField("Comment", text: $editComment)
                                    .onSubmit {
                                        updateItem(comment: editComment)
                                    }
                            }
                        }
                    }
                    
                    Divider()
                        .padding(.vertical)
                    
                    HStack(spacing: 16) {
                        
                        Color.clear.frame(width: 88, height: 0)
                        
                        VStack(alignment: .leading) {
                            
                            Group {
                                if itemValid {
                                    if let inventoryItem = inventoryItem {
                                        HStack {
                                            Text("Update inventory")
                                            InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                                            Text("􀅈")
                                        }
                                    } else {
                                        Text("New lot 􀫸")
                                    }
                                }
                            }
                            .font(.title3)
                            .padding(.bottom)
                            
                            Grid(alignment: .leading, verticalSpacing: 6) {
                                
                                GridRow {
                                    
                                    Text("Quantity").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                    
                                    HStack {
                                        TextField("Qty", value: $editQty, format: .number)
                                            .onSubmit({
                                                updateItem(qty: editQty)
                                            })
                                        
                                        Button {
                                            updateItem(qty: (uploadItem.qty ?? 0) + 1)
                                        } label: {
                                            Text("􀅼")
                                        }
                                        
                                        Button {
                                            updateItem(qty: (uploadItem.qty ?? 0) - 1)
                                        } label: {
                                            Text("􀅽")
                                        }
                                        
                                        if let inventoryItem = inventoryItem {
                                            if let qty = uploadItem.qty {
                                                Text("(\(inventoryItem.quantity) 􁉂 \(inventoryItem.quantity + qty))")
                                            } else {
                                                Text("(\(inventoryItem.quantity) 􁉂 _)")
                                            }
                                        } else {
                                            Text("")
                                        }
                                    }
                                }
                                
                                GridRow {
                                    
                                    Text("Unit price").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                    
                                    HStack {
                                        TextField("Price", value: $editUnitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                            .onSubmit({
                                                updateItem(unitPrice: editUnitPrice)
                                            })
                                        
                                        if let inventoryItem = inventoryItem {
                                            
                                            HStack(spacing: 0) {
                                                Text("(")
                                                Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).fixedSize()
                                                Text(")")
                                            }
                                        } else {
                                            Text("")
                                        }
                                        
                                        if let price = uploadItem.unitPrice, let inventoryItem = inventoryItem, price != inventoryItem.unitPrice {
                                            
                                            Button {
                                                editUnitPrice = inventoryItem.unitPrice
                                                updateItem(unitPrice: editUnitPrice)
                                            } label: {
                                                Text("Keep existing price")
                                            }
                                            .fixedSize()
                                        }
                                    }
                                }
                                
                                GridRow {
                                    
                                    Text("Remarks").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                    
                                    HStack {
                                        TextField("Remarks", text: $editRemarks, prompt: Text("Required")).fixedSize()
                                        
                                        if let inventoryItem = inventoryItem {
                                            Text("(\(inventoryItem.remarks))").fixedSize()
                                        } else {
                                            Text("")
                                        }
                                    }
                                }
                                
                                GridRow {
                                    
                                    Text("Suggested").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                                    
                                    Group {
                                        if suggestedLocations.isEmpty {
                                            
                                            Text("no suggestions").foregroundStyle(.secondary)
                                            
                                        } else {
                                            
                                            ScrollView(.horizontal) {
                                                HStack {
                                                    ForEach(suggestedLocations, id: \.self) { location in
                                                        Button {
                                                            self.editRemarks = location
                                                        } label: {
                                                            Text(location)
                                                        }
                                                    }
                                                }
                                            }
                                            .scrollIndicators(.hidden)
                                        }
                                    }
                                    .gridCellColumns(3)
                                }
                                
                                Color.clear.frame(width: 0, height: 12)
                                
                                GridRow {
                                    
                                    Color.clear.frame(width: 0)
                                    
                                    HStack(spacing: 12) {
                                        
                                        let submitType = uploadItem.type
                                        let submitRef = uploadItem.ref.normalizedOptional
                                        let submitName = uploadItem.name
                                        let submitColorId = uploadItem.colorId
                                        let submitCondition = uploadItem.condition.normalizedOptional
                                        let submitComment = uploadItem.comment
                                        let submitQty = uploadItem.qty.normalizedOptional
                                        let submitUnitPrice = uploadItem.unitPrice.normalizedOptional
                                        let submitRemarks = editRemarks.normalizedOptional
                                        
                                        let buttonDisabled = submitting
                                        || submitRef == nil
                                        || submitCondition == nil
                                        || submitQty == nil
                                        || submitUnitPrice == nil
                                        || submitRemarks == nil
                                        
                                        Button {
                                            
                                            Task {
                                                
                                                submitting = true
                                                
                                                let qtyBefore = inventoryItem?.quantity
                                                let priceBefore = inventoryItem?.unitPrice
                                                let remarksBefore = inventoryItem?.remarks
                                                let inventoryStatus = inventoryItem != nil ? UploadInventoryStatus.updated : .created
                                                
                                                let updatedOrCreatedInventoryItem = await {
                                                    
                                                    if let inventoryItem = inventoryItem {
                                                        
                                                        await inventoryStore.updateInventory(
                                                            
                                                            inventoryId: inventoryItem.id,
                                                            addQuantity: submitQty!,
                                                            unitPrice: submitUnitPrice!,
                                                            remarks: submitRemarks!
                                                        )
                                                        
                                                        return inventoryItem
                                                        
                                                    } else {
                                                        
                                                        let inventoryItem = await inventoryStore.createInventory(
                                                            
                                                            ref: submitRef!,
                                                            type: submitType,
                                                            colorId: submitColorId,
                                                            quantity: submitQty!,
                                                            unitPrice: submitUnitPrice!,
                                                            condition: submitCondition!,
                                                            description: submitComment,
                                                            remarks: submitRemarks!
                                                        )!
                                                        
                                                        return inventoryItem
                                                    }
                                                }()
                                                
                                                uploadStore.add(UploadedItem(
                                                    type: submitType,
                                                    ref: submitRef!,
                                                    name: submitName,
                                                    colorId: submitColorId,
                                                    qtyBefore: qtyBefore,
                                                    qtyAfter:  (qtyBefore ?? 0) + submitQty!,
                                                    condition: submitCondition!,
                                                    comment: submitComment,
                                                    remarksBefore: remarksBefore,
                                                    remarksAfter: submitRemarks!,
                                                    unitPriceBefore: priceBefore,
                                                    unitPriceAfter: submitUnitPrice!,
                                                    inventoryId: updatedOrCreatedInventoryItem.id,
                                                    uploadDate: .now,
                                                    inventoryStatus: inventoryStatus
                                                ))
                                                
                                                uploadStore.delete(uploadItem)
                                                
                                                submitting = false
                                            }
                                            
                                        } label: {
                                            if submitting {
                                                Text("􀈧 Uploading...").padding(.horizontal)
                                            } else {
                                                Text("􀈧 Upload").padding(.horizontal)
                                            }
                                        }
                                        .disabled(buttonDisabled)
                                        .fixedSize()
                                        
                                        Button {
                                            uploadStore.delete(uploadItem)
                                        } label: {
                                            Text("􀈑 Delete")
                                        }
                                        .fixedSize()
                                        
                                        let submitErrors = {
                                            
                                            var errors = [String]()
                                            
                                            if submitQty == nil {
                                                errors.append("missing valid qty")
                                            }
                                            
                                            if submitUnitPrice == nil {
                                                errors.append("missing valid price")
                                            }
                                            
                                            if submitRemarks == nil {
                                                errors.append("missing valid remarks")
                                            }
                                            
                                            return errors
                                        }()
                                        
                                        Text((submitErrors+itemErrors).joined(separator: ", ")).italic().fixedSize()
                                    }
                                    .gridCellColumns(3)
                                }
                            }
                        }
                    }
                }
                .padding()
                
                VStack {
                    
                    if validatedLocation.hasWarning {
                     
                        Text("invalid location").foregroundStyle(.secondary)
                    }
                    
                    let newLocation = validatedLocation.valueToSubmit
                    
                    InventoryTargetLocationView(newLocation: newLocation, candidateItems: [uploadItem], columnsCount: 7)
                }
                .padding(.horizontal)
            }
        }
        .onChange(of: uploadItem, initial: true) {
            
            editRef = uploadItem.ref
            editColorId = uploadItem.colorId
            editCondition = uploadItem.condition
            editComment = uploadItem.comment ?? ""
            editQty = uploadItem.qty
            editUnitPrice = uploadItem.unitPrice
        }
        
        
        //
        
        
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
        .onChange(of: [uploadItem.ref, uploadItem.colorId, uploadItem.condition, uploadItem.comment], initial: true) {
            self.editRemarks = self.inventoryItem?.remarks ?? ""
        }
    }
    
    
    var validatedLocation: ValidatedValue<Location> {
        
        if let loc = Location(from: editRemarks) {
            .init(valueToSubmit: loc, hasWarning: false)
        } else if editRemarks.isEmpty {
            .init(valueToSubmit: nil, hasWarning: false)
        } else {
            .init(valueToSubmit: nil, hasWarning: true)
        }
    }
    
    
    var inventoryItem: InventoryItem? {
        
        return inventoryStore.inventory(for: uploadItem)
    }
    
    var suggestedLocations: [String] {
        
        return uploadStore.suggestedLocations(for: uploadItem)
    }
    
    
    func updateItem(
        
        ref: String? = nil,
        name: String? = nil,
        colorId: String? = nil,
        qty: Int? = nil,
        condition: String? = nil,
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
        if let condition = uploadItem.condition {
            color(for: condition)
        } else {
            .black
        }
    }
    
    
    func color(for condition: String) -> Color {
        switch condition {
        case "U": return .red
        case "N": return .blue
        default: return .clear
        }
    }
}



extension Int? {
    
    var normalizedOptional: Int? {
        return (self ?? 0) > 0 ? self : nil
    }
}



extension Float? {
    
    var normalizedOptional: Float? {
        return (self ?? 0) > 0 ? self : nil
    }
}



extension String {
        
    var normalizedOptional: String? {
        
        let trimmed = self.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed == "" ? nil : trimmed
    }
}

extension String? {
    
    var normalizedOptional: String? { (self ?? "").normalizedOptional }
}
