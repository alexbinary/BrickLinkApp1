
import SwiftUI



struct UploadItemView: View {
    
    
    @Environment(CatalogController.self)
    var catalogController
    
    @Environment(UploadController.self)
    var uploadController
    
    @Environment(InventoryController.self)
    var inventoryController
    
    
    let uploadItem: UploadItem
    
    init(uploadItem: UploadItem) {
        
        self.uploadItem = uploadItem
        self._editColorId = State(initialValue: uploadItem.colorId)
    }
    
    
    @State var hover = false
    @State var catalogResult: Result<CatalogItem>? = nil
    
    @State var editModeRef = false
    @State var editModeColor = false
    @State var editModeCondition = false
    @State var editModeComment = false
    @State var editModeQty = false
    @State var editModePrice = false
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID
    @State var editCondition: String?
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""
    
    @State var submitting = false

    
    var body: some View {
        
        HStack(alignment: .top) {
            
            Grid(verticalSpacing: 0) {
                
                GridRow(alignment: .top) {
                    
                    CatalogImage(uploadItem: uploadItem)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
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
                        
                        Group {
                            
                            if let catalogResult = catalogResult {
                                
                                switch catalogResult {
                                    
                                case .loading:
                                    Text("Loading name from catalog...").foregroundStyle(.secondary)
                                    
                                case .found(let catalogItem):
                                    Text(catalogItem.name).lineLimit(nil)
                                    
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
                        
                        Text(uploadItem.condition != nil ? (uploadItem.condition == "U" ? "USED" : "NEW") : "-").font(.title3)
                            .onTapGesture { editModeCondition = true }
                            .opacity(editModeCondition ? 0 : 1)
                        
                        Picker("Condition", selection: $editCondition) {
                            
                            Text("").tag(nil as String?)
                            Text("NEW").tag("N")
                            Text("USED").tag("U")
                        }
                        .labelsHidden()
                        .frame(maxWidth: 90)
                        .onChange(of: editCondition) {
                            editModeCondition = false
                        }
                        .opacity(editModeCondition ? 1 : 0)
                        
                    }.gridColumnAlignment(.center)
                    
                    HStack {
                        LegoColorView(uploadItem: uploadItem, style: .compact)
                        
                        ZStack(alignment: .leading) {
                            
                            Text(catalogController.colorName(forLegoColorId: uploadItem.colorId))
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
                    .gridColumnAlignment(.leading)
                }
            }
            
            let errors: [String] = {
                
                var errors = [String]()
                
                if uploadItem.ref.normalizedOptional == nil {
                    errors.append("invalid item ref")
                }
                
                if uploadItem.condition.normalizedOptional == nil {
                    errors.append("missing condition")
                }
                
                return errors
            }()
            
            if !errors.isEmpty {
                
                VStack(alignment: .leading) {
                    
                    ForEach(errors, id: \.self) { error in
                        Text(error)
                    }
                }
                .italic()
                
            } else {
                    
                Grid(alignment: .leading, verticalSpacing: 12) {
                    
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Inventory ID").foregroundStyle(.secondary).gridColumnAlignment(.trailing)
                        if let inventoryItem = inventoryItem {
                            InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                        } else {
                            Text("-")
                        }
                    }
                    
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Action").foregroundStyle(.secondary)
                        Text(inventoryItem == nil ? "Create 􀫸" : "Update 􀅈")
                    }
                }
                .frame(width: 200)
                
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
                                updateItem()
                            } label: {
                                Text("Keep existing price")
                            }
                            .fixedSize()
                        }
                    }
                    
                    GridRow(alignment: .firstTextBaseline) {
                        Text("Remarks").foregroundStyle(.secondary)
                        
                        TextField("Remarks", text: $editRemarks, prompt: Text("Required")).frame(width: 80).fixedSize()
                        
                        if let inventoryItem = inventoryItem {
                            Text("(\(inventoryItem.remarks))").fixedSize()
                        } else {
                            Text("")
                        }
                    }
                    
                    GridRow {
                        
                        Color.clear.frame(width: 0)
                        
                        Group {
                            if relatedInventories.isEmpty {
                                
                                Text("no similar part").foregroundStyle(.secondary)
                                
                            } else {
                                
                                let remarks = relatedInventories.map { $0.remarks }
                                    .unique .sorted()
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(remarks, id: \.self) { rem in
                                            Button {
                                                self.editRemarks = rem
                                            } label: {
                                                Text(rem)
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
                                            
                                            await inventoryController.updateInventory(
                                                
                                                id: inventoryItem.id,
                                                addQuantity: submitQty!,
                                                unitPrice: submitUnitPrice!,
                                                remarks: submitRemarks!
                                            )
                                            
                                            return inventoryItem
                                            
                                        } else {
                                            
                                            let inventoryItem = await inventoryController.createInventory(
                                                
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

                                    uploadController.add(UploadedItem(
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
                                    
                                    uploadController.delete(uploadItem)
                                    
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
                                uploadController.delete(uploadItem)
                            } label: {
                                Text("􀈑 Delete")
                            }
                            .fixedSize()
                            
                            let errors = {
                                
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
                            
                            Text(errors.joined(separator: ", ")).italic().fixedSize()
                        }
                        .gridCellColumns(3)
                    }
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
            uploadController.update(UploadItem(
                
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
    
    
    var inventoryItem: InventoryItem? {
        
        if uploadItem.condition == nil {
            return nil
        }
        return inventoryController.inventory(for: uploadItem)
    }
    
    var relatedInventories: [InventoryItem] {
        
        if uploadItem.condition == nil {
            return []
        }
        return inventoryController.inventories(forAllColorsOf: uploadItem)
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
        
        uploadController.update(UploadItem(
            
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
        
        if let catalog = await catalogController.getCatalogItem(forItemType: uploadItem.type, ref: uploadItem.ref) {
            
            self.catalogResult = .found(catalog)
            updateItem(name: catalog.name)
        } else {
            self.catalogResult = .notFound
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
