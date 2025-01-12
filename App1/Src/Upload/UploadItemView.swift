
import SwiftUI



struct UploadItemView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let uploadItem: UploadItem
    
    @State var hover = false
    @State var waitingActivation = true
    
    @State var catalogResult: Result<CatalogItem>? = nil
    @State var inventoryResult: Result<InventoryItem>? = nil
    @State var relatedInventoriesResult: Result<[InventoryItem]>? = nil
    
    @State var editModeRef = false
    @State var editModeColor = false
    @State var editModeCondition = false
    @State var editModeComment = false
    @State var editModeQty = false
    @State var editModePrice = false
    
    @State var editRef: String = ""
    @State var editColorId: LegoColor.ID = ""
    @State var editCondition: String?
    @State var editComment: String = ""
    @State var editQty: Int?
    @State var editUnitPrice: Float?
    @State var editRemarks: String = ""

    
    var body: some View {
        
        HStack(alignment: .top) {
            
            HStack(alignment: .center, spacing: 48) {
                
                Grid(verticalSpacing: 0) {
                    
                    GridRow(alignment: .top) {
                        
                        AsyncImage(url: appController.imageUrl(forItemType: uploadItem.type, ref: uploadItem.ref, colorId: uploadItem.colorId))
                            .frame(minHeight: 70, maxHeight: 70, alignment: .top)
                            .frame(minWidth: 90, maxWidth: 90, alignment: .top)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            
                            ZStack(alignment: .leading) {
                                
                                Text(uploadItem.ref)
                                    .onTapGesture {
                                        editModeRef = true
                                    }
                                    .font(.caption).foregroundStyle(.secondary)
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
                                
                                if waitingActivation, let name = uploadItem.name {
                                    Text(name).lineLimit(nil)
                                    
                                } else if let catalogResult = catalogResult {
                                        
                                    switch catalogResult {
                                    
                                    case .loading:
                                        Text("Loading name from catalog...").foregroundStyle(.secondary)
                                        
                                    case .found(let catalogItem):
                                        Text(catalogItem.name).lineLimit(nil)
                                        
                                    case .notFound:
                                        Text("no catalog entry").foregroundStyle(.secondary)
                                    }
                                    
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
                                .onTapGesture {
                                    editModeComment = true
                                }
                                .opacity(editModeComment ? 0 : 1)
                                
                                TextField("Comment", text: $editComment)
                                    .frame(maxWidth: 200)
                                    .onSubmit({
                                        editModeComment = false
                                    })
                                    .opacity(editModeComment ? 1 : 0)
                            }
                        }
                    }
                    
                    GridRow {
                        
                        ZStack {
                            
                            Text(uploadItem.condition != nil ? (uploadItem.condition == "U" ? "USED" : "NEW") : "-").font(.title3)
                                .onTapGesture {
                                    editModeCondition = true
                                }
                                .opacity(editModeCondition ? 0 : 1)
                            
                            Picker("Condition", selection: $editCondition) {
                                
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
                            appController.color(forLegoColorId: uploadItem.colorId).frame(width: 18, height: 18)
                            
                            ZStack(alignment: .leading) {
                                
                                Text(appController.colorName(forLegoColorId: uploadItem.colorId))
                                    .onTapGesture {
                                        editModeColor = true
                                    }
                                    .opacity(editModeColor ? 0 : 1)
                                
                                Picker("Color", selection: $editColorId) {
                                    
                                    ForEach(appController.allColors) { color in
                                        
                                        Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode))
                                            .tag(color.id)
                                    }
                                }
                                .pickerStyle(.menu)
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
                
                Grid(alignment: .leading, verticalSpacing: 24) {
                    
                    GridRow(alignment: .firstTextBaseline) {
                        
                        Text("Qty").foregroundStyle(.secondary)
                        
                        HStack {
                            
                            if !editModeQty {
                                
                                Button {
                                    editModeQty = false
                                    updateItem(qty: (uploadItem.qty ?? 0) - 1)
                                } label: {
                                    Text("􀅽")
                                }
                                
                                Group {
                                    if let qty = uploadItem.qty {
                                        Text("\(qty)")
                                    } else {
                                        Text("-")
                                    }
                                }
                                .font(.title2).gridColumnAlignment(.center)
                                .onTapGesture {
                                    editModeQty = true
                                }
                                
                                Button {
                                    editModeQty = false
                                    updateItem(qty: (uploadItem.qty ?? 0) + 1)
                                } label: {
                                    Text("􀅼")
                                }
                                
                            } else {
                                
                                TextField("Qty", value: $editQty, format: .number).multilineTextAlignment(.center)
                                    .frame(maxWidth: 50)
                                    .onSubmit({
                                        editModeQty = false
                                    })
                            }
                        }
                    }
                    
                    GridRow(alignment: .firstTextBaseline) {
                        
                        Text("PU").foregroundStyle(.secondary)
                        
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
            
            Divider()
                .padding(.leading, 48)
                .padding(.trailing, 12)
            
            let status: (isLoadingInventory: Bool, inventoryItem: InventoryItem?) = {
                
                if let inventoryResult = inventoryResult {
                    
                    switch inventoryResult {
                        
                    case .loading:
                        return (isLoadingInventory: true, inventoryItem: nil)
                        
                    case .found(let inventoryItem):
                        return (isLoadingInventory: false, inventoryItem: inventoryItem)
                        
                    case .notFound:
                        return (isLoadingInventory: false, inventoryItem: nil)
                    }
                    
                } else {
                    
                    return (isLoadingInventory: false, inventoryItem: nil)
                }
            }()
            
            let errors = {
                
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
                .foregroundStyle(.secondary)
                .italic()
                
            } else {
                
                if waitingActivation {
                    
                    Text("Click to activate").frame(maxHeight: .infinity)
                    
                } else if status.isLoadingInventory {
                    
                    Text("Loading inventory...").frame(maxHeight: .infinity).foregroundStyle(.secondary)
                    
                } else {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        Group {
                            if let inventoryItem = status.inventoryItem {
                                
                                HStack {
                                    Text("􀚂 Update")
                                    Link("#\(inventoryItem.id)", destination: URL(string: "https://www.bricklink.com/v2/inventory_detail.page?invID=\(inventoryItem.id)#/")!)
                                }
                                
                            } else {
                                
                                Text("􀁍 New inventory")
                            }
                        }
                        .font(.title3).foregroundStyle(.secondary)
                        
                        Grid(alignment: .leading, verticalSpacing: 8) {
                            
                            if let inventoryItem = status.inventoryItem {
                                
                                GridRow {
                                    Text("Qty :")
                                    HStack {
                                        Text("\(inventoryItem.quantity)").gridColumnAlignment(.trailing)
                                        if let qty = uploadItem.qty {
                                            Text("􁉂 \(inventoryItem.quantity + qty)")
                                        }
                                    }
                                }
                            }
                            
                            if let inventoryItem = status.inventoryItem {
                                
                                GridRow {
                                    
                                    Text("Price :")
                                    HStack {
                                        Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).fixedSize()
                                        
                                        if let price = uploadItem.unitPrice {
                                            if price != inventoryItem.unitPrice {
                                                HStack {
                                                    Text("􁉂").fixedSize()
                                                    Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).fixedSize()
                                                }
                                                Button {
                                                    editUnitPrice = inventoryItem.unitPrice
                                                    updateItem()
                                                } label: {
                                                    Text("Keep existing price")
                                                }
                                                .fixedSize()
                                            } else {
                                                Text("unchanged")
                                            }
                                        }
                                    }
                                }
                            }
                            
                            GridRow {
                                Text("Remarks :")
                                HStack {
                                    TextField("Remarks", text: $editRemarks, prompt: Text("Required")).frame(width: 80).fixedSize()
                                    
                                    if let relatedInventoriesResult = relatedInventoriesResult {
                                        
                                        switch relatedInventoriesResult {
                                        
                                        case .loading:
                                            
                                            Text("Loading related inventories...").foregroundStyle(.secondary)
                                        
                                        case .notFound:
                                            
                                            Text("no related inventory found").foregroundStyle(.secondary)
                                        
                                        case .found(let relatedInventories):
                                            
                                            let remarks = relatedInventories.map { $0.remarks }
                                                .unique .sorted()
                                            
                                            ForEach(remarks, id: \.self) { rem in
                                                Button {
                                                    self.editRemarks = rem
                                                } label: {
                                                    Text(rem)
                                                }
                                                .fixedSize()
                                            }
                                        }
                                    }
                                }
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
                                    
                                    let buttonDisabled = status.isLoadingInventory
                                    || submitRef == nil
                                    || submitCondition == nil
                                    || submitQty == nil
                                    || submitUnitPrice == nil
                                    || submitRemarks == nil
                                    
                                    Button {
                                        
                                        Task {
                                            
                                            let qtyBefore = status.inventoryItem?.quantity
                                            let priceBefore = status.inventoryItem?.unitPrice
                                            let remarksBefore = status.inventoryItem?.remarks
                                            let inventoryStatus: UploadInventoryStatus = status.inventoryItem != nil ? .updated : .created
                                            
                                            let inventoryItem = await {
                                                
                                                if let inventoryItem = status.inventoryItem {
                                                    
                                                    await appController.updateInventory(
                                                        
                                                        id: inventoryItem.id,
                                                        addQuantity: submitQty!,
                                                        unitPrice: submitUnitPrice!,
                                                        remarks: submitRemarks!
                                                    )
                                                    
                                                    return inventoryItem
                                                    
                                                } else {
                                                    
                                                    let inventoryItem = await appController.createInventory(
                                                        
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
                                            
                                            appController.addUploadedItem(UploadedItem(
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
                                                inventoryId: inventoryItem.id,
                                                uploadDate: .now,
                                                inventoryStatus: inventoryStatus
                                            ))
                                            
                                            appController.deleteUploadItem(uploadItem)
                                        }
                                        
                                    } label: {
                                        Text("􀈧 Upload").padding(.horizontal)
                                    }
                                    .disabled(buttonDisabled)
                                    .fixedSize()
                                    
                                    Button {
                                        appController.deleteUploadItem(uploadItem)
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
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: hover ? .secondarySystemFill : .tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(nsColor: .tertiarySystemFill))
        )
        .onHover { hover in
            self.hover = hover
        }
        .onTapGesture {
            waitingActivation = false
            Task {
                await parallel([
                    { await pullCatalogEntry() },
                    { await pullInventory() },
                ])
            }
        }
        
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
            Task { await pullCatalogEntry() }
        }
        .onChange(of: [uploadItem.ref, uploadItem.colorId, uploadItem.condition, uploadItem.comment], initial: false) {
            Task {
                await pullInventory()
            }
        }
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
        
        appController.updateUploadItem(UploadItem(
            
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
    
    
    func pullInventory() async {
        
        guard uploadItem.condition != nil else { return }
        
        await parallel([
            {
                self.inventoryResult = .loading
                self.editRemarks = ""
                
                if let item = await appController.getInventory(for: uploadItem) {
                    
                    self.inventoryResult = .found(item)
                    self.editRemarks = item.remarks
                } else {
                    self.inventoryResult = .notFound
                }
            },
            {
                self.relatedInventoriesResult = .loading
                let relatedInventories = await appController.getInventoriesForAllColors(for: uploadItem)
                self.relatedInventoriesResult = relatedInventories.isEmpty ? .notFound : .found(relatedInventories)
            }
        ])
    }
    
    
    func pullCatalogEntry() async {
        
        self.catalogResult = .loading
        
        appController.updateUploadItem(UploadItem(
            
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
        
        if let catalog = await appController.getCatalogItem(forItemType: uploadItem.type, ref: uploadItem.ref) {
            
            self.catalogResult = .found(catalog)
            updateItem(name: catalog.name)
        } else {
            self.catalogResult = .notFound
        }
    }
}



enum Result<T> {
    
    case loading
    case notFound
    case found(T)
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
