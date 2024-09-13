
import SwiftUI



struct UploadContentView: View {
    
    
    @EnvironmentObject var appController: AppController

    @State var type: BrickLinkItemType = .part
    @State var ref: String = ""
    @State var colorId: LegoColor.ID = ""
    @State var qty: Int = 1
    @State var condition: String = "U"
    @State var comment: String = ""
    
    
    var body: some View {
        
        VStack {
            
            HStack {
                
                Form {
                    
                    Picker("Type", selection: $type) {
                        
                        ForEach(BrickLinkItemType.allCases, id: \.self) { type in
                            
                            Text(type.rawValue).tag(type)
                        }
                    }
                    
                    TextField("Ref", text: $ref)
                    
                    Picker("Color", selection: $colorId) {
                        
                        ForEach(appController.allColors) { color in
                            
                            Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode))
                                .tag(color.id)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    TextField("Qty", value: $qty, format: .number)
                    
                    Picker("Condition", selection: $condition) {
                        
                        Text("New").tag("N")
                        Text("Used").tag("U")
                    }
                    
                    TextField("Comment", text: $comment)
                    
                    Button {
                        appController.addUploadItem(UploadItem(
                            type: type,
                            ref: ref,
                            colorId: colorId,
                            qty: qty,
                            condition: condition,
                            comment: comment)
                        )
                    } label: {
                        Text("Add")
                    }
                }
                
                AsyncImage(url: appController.imageUrl(forItemType: type, ref: ref, colorId: colorId))
                    .frame(maxWidth: 100, maxHeight: 100)
            }

            Table(appController.uploadItems) {
                
                TableColumn("Image") { item in
                    AsyncImage(url: appController.imageUrl(forItemType: item.type, ref: item.ref, colorId: item.colorId))
                }
                
                TableColumn("Condition", value: \.condition)
                
                TableColumn("Color") { item in
                    HStack {
                        appController.color(forLegoColorId: item.colorId).frame(width: 18, height: 18)
                        Text(appController.colorName(forLegoColorId: item.colorId))
                    }
                }
                
                TableColumn("Ref", value: \.ref)
                
                TableColumn("Quantity") { item in
                    Text(item.qty, format: .number)
                }
                
                TableColumn("Comment", value: \.comment)
                
                TableColumn("Delete") { item in
                    Button {
                        appController.deleteUploadItem(item)
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Upload")
    }
}
