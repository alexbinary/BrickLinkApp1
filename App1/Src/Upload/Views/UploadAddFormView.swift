
import SwiftUI



struct UploadAddFormView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!

    
    @State var type: ItemType = .part
    @State var ref: String = ""
    @State var name: String? = nil
    @State var colorId: LegoColor.ID? = "1"
    @State var qty: Int = 1
    @State var condition: ItemCondition = .used
    @State var comment: String = ""
    @State var unitPrice: Float = 0
    
    
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
                            .foregroundStyle(.secondary)
                        
                        ItemTypePicker("Type", selection: $type)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Ref")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        TextField("Ref", text: $ref)
                    }
                    
                    GridRow {
                        
                        Text("Name")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        DynamicCatalogName(forItemType: type, ref: ref, name: $name)
                    }
                    
                    GridRow {
                        
                        Text("Color")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        LegoColorPicker("Color", selection: $colorId)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Condition")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        ItemConditionPicker("Condition", selection: $condition)
                            .labelsHidden()
                    }
                    
                    GridRow {
                        
                        Text("Comment")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        TextField("Comment", text: $comment)
                    }
                    
                    GridRow {
                        
                        Text("Quantity")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            TextField("Qty", value: $qty, format: .number)
                            
                            Button {
                                qty = qty + 1
                            } label: {
                                Text("􀅼")
                            }
                            
                            Button {
                                qty = max(1, qty - 1)
                            } label: {
                                Text("􀅽")
                            }
                            .disabled(qty <= 1)
                        }
                    }
                    
                    GridRow {
                        
                        Text("Unit price")
                            .gridColumnAlignment(.trailing)
                            .foregroundStyle(.secondary)
                        
                        TextField("Price", value: $unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                    }
                    
                    GridRow {
                        
                        Color.clear.frame(width: 0, height: 0)
                        
                        Button("Add") { addItem() }
                    }
                }
                
                VStack {
                    
                    CatalogImage(
                        itemType: type,
                        ref: ref,
                        colorId: colorId ?? "",
                        scale: 1.5
                    )
                    
                    
                }
            }
        }
        .padding()
    }
    
    
    func addItem() {
        
        uploadStore.add(UploadItem(
            type: type,
            ref: ref,
            name: name,
            colorId: colorId,
            qty: qty,
            condition: condition,
            comment: comment,
            unitPrice: unitPrice
        ))
    }
}
