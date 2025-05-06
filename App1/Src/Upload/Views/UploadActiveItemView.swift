
import SwiftUI



struct UploadActiveItemView: View {
    
    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!
    
    @Environment(\.inventoryStore)
    var inventoryStore: InventoryStoreProtocol!
    
    
    let uploadItemId: UploadItem.ID
    var uploadItem: UploadItem? { uploadStore.uploadItemsForList.first(where: { $0.id == uploadItemId }) }
    
    
    @State var editingValue_type: ItemType = .part
    @State var editingValue_ref: String = ""
    @State var editingValue_colorId: LegoColor.ID?
    @State var editingValue_condition: ItemCondition?
    @State var editingValue_comment: String = ""
    @State var editingValue_quantity: Int?
    @State var editingValue_unitPrice: Float?
    @State var editingValue_remarks: String = ""
    
    @State var catalogLoading: Bool = false
    @State var catalogResult: CatalogResult? = nil
    @State var isSubmitting = false

    
    var body: some View {
        
        if let uploadItem = uploadItem {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading) {
                    
                    Text("Upload item 􁉂").font(.title2)
                        .padding(.bottom)
                    
                    HStack(alignment: .top, spacing: 16) {
                        
                        Grid(alignment: .leading) {
                            
                            GridRow {
                                
                                Text("Type")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_type.isInvalid ? .red
                                        : validatedValue_type.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_type.hasChanges)
                                
                                ItemTypePicker("Type", selection: $editingValue_type)
                                    .labelsHidden()
                                
                                Button("􀅉") { editingValue_type = savedValue_type }
                                    .opacity(validatedValue_type.hasChanges ? 1 : 0)
                            }
                            
                            GridRow {
                                
                                Text("Ref")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_ref.isInvalid ? .red
                                        : validatedValue_ref.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_ref.hasChanges)
                                
                                TextField("Ref", text: $editingValue_ref)
                                    .onSubmit({
                                        if editingValue_ref.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                                            editingValue_ref = uploadItem.ref
                                        }
                                    })
                                
                                Button("􀅉") { editingValue_ref = savedValue_ref }
                                    .opacity(validatedValue_ref.hasChanges ? 1 : 0)
                            }
                            
                            GridRow {
                                
                                Text("Name")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_name.isInvalid ? .red
                                        : validatedValue_name.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_name.hasChanges)
                                
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
                                            
                                        } else if let name = uploadItem.name {
                                            
                                            Text(name)
                                                .lineLimit(nil)
                                                .font(.title3)
                                            
                                        } else {
                                            
                                            Text("-")
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
                                        validatedValue_colorId.isInvalid ? .red
                                        : validatedValue_colorId.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_colorId.hasChanges)
                                
                                LegoColorPicker("Color", selection: $editingValue_colorId)
                                    .labelsHidden()
                                
                                Button("􀅉") { editingValue_colorId = savedValue_colorId }
                                    .opacity(validatedValue_colorId.hasChanges ? 1 : 0)
                            }
                            
                            GridRow {
                                
                                Text("Condition")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_condition.isInvalid ? .red
                                        : validatedValue_condition.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_condition.hasChanges)
                                
                                Picker("Condition", selection: $editingValue_condition) {
                                    
                                    Text("").tag(nil as ItemCondition?)
                                    Text("NEW")
                                        .foregroundStyle(ItemCondition.new.color)
                                        .fontWeight(.bold)
                                        .tag(ItemCondition.new)
                                    Text("USED")
                                        .foregroundStyle(ItemCondition.used.color)
                                        .fontWeight(.bold)
                                        .tag(ItemCondition.used)
                                }
                                .labelsHidden()
                                
                                Button("􀅉") { editingValue_condition = savedValue_condition }
                                    .opacity(validatedValue_condition.hasChanges ? 1 : 0)
                            }
                            
                            GridRow {
                                
                                Text("Comment")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_comment.isInvalid ? .red
                                        : validatedValue_comment.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_comment.hasChanges)
                                
                                TextField("Comment", text: $editingValue_comment)
                                
                                Button("􀅉") { editingValue_comment = savedValue_comment }
                                    .opacity(validatedValue_comment.hasChanges ? 1 : 0)
                            }
                        }
                        
                        VStack {
                            CatalogImage(
                                itemType: editingValue_type,
                                ref: editingValue_ref,
                                colorId: editingValue_colorId ?? "",
                                scale: 2
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
                    
                    if itemIsValid {
                        
                        Group {
                            
                            if let inventoryItem = inventoryItem {
                                HStack {
                                    Text("Updating lot")
                                    InventoryLink(inventoryItem) { Text("\(inventoryItem.id)") }
                                    if let loc = Location(from: inventoryItem.remarks) {
                                        HStack {
                                            Text("currently in")
                                            Text("\(loc)").bold()
                                        }
                                        .foregroundStyle(.secondary)
                                        .font(.body)
                                    }
                                }
                            } else {
                                Text("This is a new lot 􀫸")
                            }
                        }
                        .font(.title3)
                        .padding(.vertical)
                        .padding(.top)
                        
                        Grid(alignment: .leading, verticalSpacing: 6) {
                            
                            if inventoryItem != nil {
                                GridRow {
                                    Text("")
                                    Text("")
                                    Text("Before")
                                    Text("After")
                                }
                                .foregroundStyle(.secondary)
                            }
                            
                            GridRow {
                                
                                Text("Quantity")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_quantity.isInvalid ? .red
                                        : validatedValue_quantity.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_quantity.hasChanges)
                                
                                HStack {
                                    TextField("Qty", value: $editingValue_quantity, format: .number)
                                    
                                    Button {
                                        editingValue_quantity = (editingValue_quantity ?? 0) + 1
                                    } label: {
                                        Text("􀅼")
                                    }
                                    
                                    Button {
                                        editingValue_quantity = max(1, (editingValue_quantity ?? 0) - 1)
                                    } label: {
                                        Text("􀅽")
                                    }
                                    .disabled(editingValue_quantity ?? 0 <= 1)
                                }
                                
                                if let inventoryItem = inventoryItem {
                                    
                                    Text("\(inventoryItem.quantity)").gridColumnAlignment(.center).font(.title3)
                                    
                                    if let qty = validatedValue_quantity.submitValue {
                                        Text("􁉂 \(inventoryItem.quantity + qty)").gridColumnAlignment(.center).font(.title3)
                                    } else {
                                        Text("")
                                    }
                                }
                                
                                Button("􀅉") { editingValue_quantity = savedValue_quantity }
                                    .opacity(validatedValue_quantity.hasChanges ? 1 : 0)
                            }
                            
                            GridRow {
                                
                                Text("Unit price")
                                    .gridColumnAlignment(.trailing)
                                    .foregroundStyle(
                                        validatedValue_unitPrice.isInvalid ? .red
                                        : validatedValue_unitPrice.hasChanges ? .blue
                                        : .secondary
                                    )
                                    .italic(validatedValue_unitPrice.hasChanges)
                                
                                HStack {
                                    TextField("Price", value: $editingValue_unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                                    
                                    if let inventoryItem = inventoryItem,
                                       validatedValue_unitPrice.submitValue != inventoryItem.unitPrice
                                    {
                                        Button("keep existing") {
                                            editingValue_unitPrice = inventoryItem.unitPrice
                                        }
                                    }
                                }
                                
                                if let inventoryItem = inventoryItem {
                                    
                                    Text(inventoryItem.unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).font(.title3)
                                    
                                    if let price = validatedValue_unitPrice.submitValue {
                                        if price != inventoryItem.unitPrice {
                                            HStack {
                                                Text("􁉂")
                                                Text(price, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4))).font(.title3)
                                            }
                                        } else {
                                            Text("unchanged")
                                        }
                                    } else {
                                        Text("")
                                    }
                                }
                                
                                Button("􀅉") { editingValue_unitPrice = savedValue_unitPrice }
                                    .opacity(validatedValue_unitPrice.hasChanges ? 1 : 0)
                            }
                            
                            if let inventoryItem = inventoryItem {
                                
                                GridRow {
                                    
                                    Text("Location")
                                        .gridColumnAlignment(.trailing)
                                        .foregroundStyle(.secondary)
                                    
                                    Text("")
                                    
                                    Text(inventoryItem.remarks).font(.title3)
                                    
                                    if let loc = validatedValue_location.submitValue {
                                        if loc.textRepresentation == inventoryItem.remarks {
                                            Text("unchanged")
                                        } else {
                                            Text("􁉂 \(loc)").font(.title3)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                
                VStack(alignment: .leading) {
                    
                    Text("Location 􁉂􀈫").font(.title2)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading) {
                        
                        HStack {
                            
                            TextField("Location", text: $editingValue_remarks)
                                .frame(width: 100)
                            
                            if let inventoryItem = inventoryItem {
                                Button("􀅉") { editingValue_remarks = inventoryItem.remarks }
                            }
                            
                            Color.clear.frame(width: 16, height: 0)
                            
                            if !suggestedLocations.isEmpty {
                                
                                Text("suggested: ").italic().foregroundStyle(.secondary)
                                
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(suggestedLocations, id: \.self) { location in
                                            Button {
                                                self.editingValue_remarks = location
                                            } label: {
                                                Text(location)
                                            }
                                        }
                                    }
                                }
                                .scrollIndicators(.hidden)
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    Group {
                        if let loc = validatedValue_location.submitValue {
                            
                            if let inventoryItem = inventoryItem {
                                
                                if loc.textRepresentation == inventoryItem.remarks {
                                    HStack {
                                        Text("This will add new items to existing lot in")
                                        Text("\(loc)").bold()
                                    }
                                } else {
                                    HStack {
                                        Text("This will move existing lot to")
                                        Text("\(loc)").bold()
                                        Text("and add new items there")
                                    }
                                }
                                
                            } else {
                                
                                HStack {
                                    Text("This will create a new lot in")
                                    Text("\(loc)").bold()
                                }
                            }
                        }
                    }
                    .padding(.bottom)
                    
                    HStack {
                        
                        Button {
                            Task { await upload() }
                        } label: {
                            Text("􀈧 Upload").padding(.horizontal)
                        }
                        .disabled(!canUpload)
                        
                        if isSubmitting {
                            ProgressView().controlSize(.small)
                        }
                        
                        Spacer()
                        
                        if hasChanges {
                            
                            Button {
                                saveChanges()
                            } label: {
                                Text("􀈽 Save changes")
                            }
                            .disabled(!canSaveChanges)
                        }
                        
                        Button {
                            deleteUploadItem()
                        } label: {
                            Text("􀈑 Delete")
                        }
                    }
                    
                    Divider().padding(.top)
                    
                    Group {
                        
                        if itemValidity != .indeterminate {
                            
                            if itemIsInvalid {
                                
                                Text("􀁑 cannot upload: item is invalid")
                                    .italic()
                                    .foregroundStyle(.red)
                                
                            } else if validatedValue_quantity.isInvalid || validatedValue_unitPrice.isInvalid {
                                
                                Text("􀁑 cannot upload: invalid quantity and/or unit price")
                                    .italic()
                                    .foregroundStyle(.red)
                                
                            } else if validatedValue_location.isInvalid {
                                
                                Group {
                                    if editingValue_remarks.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        Text("􀇿 no location specified")
                                    } else {
                                        Text("􀇿 invalid location")
                                    }
                                }
                                .italic()
                                .foregroundStyle(.orange)
                                
                            } else {
                                
                                InventoryTargetLocationView(
                                    newLocation: validatedValue_location.submitValue,
                                    candidateItems: [PartDescriptor(
                                        item_type: validatedValue_type.submitValue,
                                        item_ref: validatedValue_ref.submitValue,
                                        item_colorId: validatedValue_colorId.submitValue,
                                        item_condition: validatedValue_condition.submitValue
                                    )],
                                    highlightItems: inventoryItem != nil ? [inventoryItem!.id] : [],
                                    columnsCount: 6,
                                    
                                )
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .padding()
            }
            
            // init edit values
            
            .onChange(of: uploadItem.type, initial: true) {
                
                editingValue_type = uploadItem.type
            }
            .onChange(of: uploadItem.ref, initial: true) {
                
                editingValue_ref = uploadItem.ref
            }
            .onChange(of: uploadItem.colorId, initial: true) {
                
                editingValue_colorId = uploadItem.colorId
            }
            .onChange(of: uploadItem.condition, initial: true) {
                
                editingValue_condition = uploadItem.condition
            }
            .onChange(of: uploadItem.comment, initial: true) {
                
                editingValue_comment = uploadItem.comment ?? ""
            }
            .onChange(of: uploadItem.qty, initial: true) {
                
                editingValue_quantity = uploadItem.qty
            }
            .onChange(of: uploadItem.unitPrice, initial: true) {
                
                editingValue_unitPrice = uploadItem.unitPrice
            }
            
            // update catalog entry
            
            .onChange(of: uploadItem.name, initial: true) { old, new in
                if new == nil {
                    Task { await refreshCatalogEntry() }
                }
            }
            .onChange(of: editingValue_type, initial: true) {
                
                catalogResult = nil
                Task { await refreshCatalogEntry() }
            }
            .onChange(of: editingValue_ref, initial: true) {
                
                catalogResult = nil
                Task { await refreshCatalogEntry() }
            }
            
            //
            
            .onChange(of: inventoryItem, initial: true) {
                
                self.editingValue_remarks = inventoryItem?.remarks ?? ""
            }
        }
    }
    
    
    var validatedValue_type: ValidatedValue<ItemType> {
        
        .init(
            submitValue: editingValue_type, validity: .valid,
            hasChanges: editingValue_type != savedValue_type
        )
    }
    
    var validatedValue_ref: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.ref,
            validity: catalogLoading ? .indeterminate : .valid,
            hasChanges: entry.ref != savedValue_ref
        )
        default: .init(
            
            submitValue: editingValue_ref,
            validity: (catalogResult == nil || catalogLoading) ? .indeterminate : .invalid,
            hasChanges: editingValue_ref != savedValue_ref
        )
        }
    }
    
    var validatedValue_name: ValidatedValue<String> {
        
        switch catalogResult {
            
        case .found(let entry): .init(
            
            submitValue: entry.name,
            validity: catalogLoading ? .indeterminate : .valid,
            hasChanges: entry.name != savedValue_name
        )
        default: .init(
            
            submitValue: nil,
            validity: (catalogResult == nil || catalogLoading) ? .indeterminate : .invalid,
            hasChanges: (catalogResult == nil || catalogLoading) ? false : "" != (savedValue_name ?? "")
        )
        }
    }
    
    var validatedValue_colorId: ValidatedValue<LegoColor.ID> {
        
        if let colorId = editingValue_colorId {
            
            return .init(
                submitValue: colorId, validity: .valid,
                hasChanges: colorId != savedValue_colorId
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_colorId != savedValue_colorId
            )
        }
    }
    
    var validatedValue_condition: ValidatedValue<ItemCondition> {
        
        if let condition = editingValue_condition {
            
            return .init(
                submitValue: condition, validity: .valid,
                hasChanges: condition != savedValue_condition
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_condition != savedValue_condition
            )
        }
    }
    
    var validatedValue_comment: ValidatedValue<String> {
        
        .init(
            submitValue: editingValue_comment, validity: .valid,
            hasChanges: editingValue_comment != savedValue_comment
        )
    }
    
    var validatedValue_quantity: ValidatedValue<Int> {
        
        if let qty = editingValue_quantity, qty > 0 {
        
            return .init(
                submitValue: qty, validity: .valid,
                hasChanges: qty != savedValue_quantity
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_quantity != savedValue_quantity
            )
        }
    }
    
    var validatedValue_unitPrice: ValidatedValue<Float> {
        
        if let price = editingValue_unitPrice, price > 0 {
        
            return .init(
                submitValue: price, validity: .valid,
                hasChanges: price != savedValue_unitPrice
            )
            
        } else {
            
            return .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_unitPrice != savedValue_unitPrice
            )
        }
    }
    
    var validatedValue_remarks: ValidatedValue<String> {
        
        if let loc = Location(from: editingValue_remarks) {
            
            .init(
                submitValue: loc.textRepresentation, validity: .valid,
                hasChanges: loc.textRepresentation != inventoryItem?.remarks
            )
            
        } else {
            
            .init(
                submitValue: editingValue_remarks, validity: .valid,
                hasChanges: editingValue_remarks != inventoryItem?.remarks
            )
        }
    }
    
    var validatedValue_location: ValidatedValue<Location> {
        
        if let loc = Location(from: editingValue_remarks) {
            
            .init(
                submitValue: loc, validity: .valid,
                hasChanges: loc.textRepresentation != inventoryItem?.remarks
            )
            
        } else {
            
            .init(
                submitValue: nil, validity: .invalid,
                hasChanges: editingValue_remarks != inventoryItem?.remarks
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
    
    
    var itemValidity: Validity {
        
        return [
            validatedValue_type.validity,
            validatedValue_ref.validity,
            validatedValue_colorId.validity,
            validatedValue_condition.validity,
        ].reduce(.valid) { total, item in
            if total == .invalid { return .invalid }
            if item != .valid { return item }
            return total
        }
    }
    
    var itemIsValid: Bool { itemValidity == .valid }
    var itemIsInvalid: Bool { itemValidity == .invalid }
    
    
    var inventoryItem: InventoryItem? {
        
        if itemIsValid {
        
            return inventoryStore.inventory(
                
                forItemType: validatedValue_type.submitValue!,
                ref: validatedValue_ref.submitValue!,
                comment: validatedValue_comment.submitValue,
                colorId: validatedValue_colorId.submitValue!,
                condition: validatedValue_condition.submitValue!
            )
        } else {
            return nil
        }
    }
    
    
    var suggestedLocations: [String] {
        
        if itemIsValid {
           
            return uploadStore.suggestedLocations(
                
                forItemType: validatedValue_type.submitValue!,
                ref: validatedValue_ref.submitValue!,
                comment: validatedValue_comment.submitValue,
                condition: validatedValue_condition.submitValue!
            )
        } else {
            return []
        }
    }
    
    
    var savedValue_type: ItemType { uploadItem!.type }
    var savedValue_ref: String { uploadItem!.ref }
    var savedValue_name: String? { uploadItem!.name }
    var savedValue_colorId: LegoColor.ID? { uploadItem!.colorId }
    var savedValue_condition: ItemCondition? { uploadItem!.condition }
    var savedValue_comment: String { uploadItem!.comment ?? "" }
    var savedValue_quantity: Int? { uploadItem!.qty }
    var savedValue_unitPrice: Float? { uploadItem!.unitPrice }
    
    
    var hasChanges: Bool {
        
        validatedValue_type.hasChanges
        ||
        validatedValue_ref.hasChanges
        ||
        validatedValue_colorId.hasChanges
        ||
        validatedValue_condition.hasChanges
        ||
        validatedValue_comment.hasChanges
        ||
        validatedValue_quantity.hasChanges
        ||
        validatedValue_unitPrice.hasChanges
    }
    
    
    var canSaveChanges: Bool {
        
        true
    }
    
    
    func saveChanges() {
        
        uploadStore.update(UploadItem(
            
            id: uploadItem!.id,
            type: validatedValue_type.submitValue!,
            ref: validatedValue_ref.submitValue!,
            name: validatedValue_name.submitValue ?? savedValue_name,
            colorId: validatedValue_colorId.submitValue,
            qty: validatedValue_quantity.submitValue!,
            condition: validatedValue_condition.submitValue!,
            comment: validatedValue_comment.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue
        ))
    }
    
    
    func deleteUploadItem() {
        
        uploadStore.delete(uploadItem!)
    }
    
    
    var canUpload: Bool {
        
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
            &&
            validatedValue_remarks.isValid
    }
    
    
    func upload() async {
        
        isSubmitting = true
        
        let updatedOrCreatedInventoryItem = await createOrUpdateInventory()
        addUploadedItem(inventoryId: updatedOrCreatedInventoryItem.id)
        deleteUploadItem()
        
        isSubmitting = false
    }
    
    
    func updateInventory(id: InventoryItem.ID) async {
        
        await inventoryStore.updateInventory(
            
            inventoryId: id,
            addQuantity: validatedValue_quantity.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue!,
            remarks: validatedValue_remarks.submitValue!
        )
    }
    
    
    func createInventory() async -> InventoryItem {
        
        await inventoryStore.createInventory(
            
            ref: validatedValue_ref.submitValue!,
            type: validatedValue_type.submitValue!,
            colorId: validatedValue_colorId.submitValue!,
            quantity: validatedValue_quantity.submitValue!,
            unitPrice: validatedValue_unitPrice.submitValue!,
            condition: validatedValue_condition.submitValue!,
            description: validatedValue_comment.submitValue!,
            remarks: validatedValue_remarks.submitValue!
        )!
    }
    
    
    func createOrUpdateInventory() async -> InventoryItem {
        
        if let inventoryItem = inventoryItem {
            await updateInventory(id: inventoryItem.id)
            return inventoryItem
        } else {
            return await createInventory()
        }
    }
    
    
    func addUploadedItem(inventoryId: InventoryItem.ID) {
        
        let qtyBefore = inventoryItem?.quantity
        let priceBefore = inventoryItem?.unitPrice
        let remarksBefore = inventoryItem?.remarks
        let inventoryStatus = inventoryItem != nil ? UploadInventoryStatus.updated : .created
        
        uploadStore.add(UploadedItem(
            type: validatedValue_type.submitValue!,
            ref: validatedValue_ref.submitValue!,
            name: validatedValue_name.submitValue!,
            colorId: validatedValue_colorId.submitValue!,
            qtyBefore: qtyBefore,
            qtyAfter:  (qtyBefore ?? 0) + validatedValue_quantity.submitValue!,
            condition: validatedValue_condition.submitValue!,
            comment: validatedValue_comment.submitValue!,
            remarksBefore: remarksBefore,
            remarksAfter: validatedValue_remarks.submitValue!,
            unitPriceBefore: priceBefore,
            unitPriceAfter: validatedValue_unitPrice.submitValue!,
            inventoryId: inventoryId,
            uploadDate: .now,
            inventoryStatus: inventoryStatus
        ))
    }
}



enum CatalogResult {
    
    case notFound
    case found(CatalogEntry)
}
