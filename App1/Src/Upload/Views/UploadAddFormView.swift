
import SwiftUI



struct UploadAddFormView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!

    
    @State var type: ItemType = .part
    @State var ref: String = ""
    @State var name: String? = nil
    @State var colorId: LegoColor.ID?
    @State var qty: Int = 1
    @State var condition: ItemCondition = .used
    @State var comment: String = ""
    @State var unitPrice: Float = 0
    
    
    var body: some View {
            
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Add item").font(.title2)
                Spacer()
                Text("􁚛")
            }
            
            HStack(alignment: .top) {
                
                Form {
                    
                    ItemTypePicker("Type", selection: $type)
                        
                    TextField("Ref", text: $ref)
                    
                    DynamicCatalogName(forItemType: type, ref: ref, name: $name)
                    
                    LegoColorPicker("Color", selection: $colorId)
                    
                    TextField("Qty", value: $qty, format: .number)
                    
                    TextField("Price", value: $unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                    
                    ItemConditionPicker("Condition", selection: $condition)
                    
                    TextField("Comment", text: $comment)
                    
                    Button("Add") {
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
                    
                CatalogImage(itemType: type, ref: ref, colorId: colorId ?? "")
            }
        }
        .padding()
    }
}
