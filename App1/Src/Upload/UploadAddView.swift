
import SwiftUI



struct UploadAddView: View {
    
    
    @EnvironmentObject var appController: AppController

    @State var type: BrickLinkItemType = .part
    @State var ref: String = ""
    @State var colorId: LegoColor.ID = ""
    @State var qty: Int = 1
    @State var condition: String = "U"
    @State var comment: String = ""
    @State var unitPrice: Float = 0
    @State var importText: String = ""
    
    
    var body: some View {
            
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􁚛 Manual add")
                    
                    HStack(alignment: .top) {
                        
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
                            
                            TextField("Price", value: $unitPrice, format: .currency(code: "EUR").presentation(.isoCode).precision(.fractionLength(4)))
                            
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
                                    comment: comment,
                                    unitPrice: unitPrice
                                ))
                            } label: {
                                Text("Add")
                            }
                        }
                        
                        AsyncImage(url: appController.imageUrl(forItemType: type, ref: ref, colorId: colorId))
                            .frame(maxWidth: 100, maxHeight: 100)
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􀈄 XML import")
                    
                    VStack(alignment: .leading) {
                        
                        TextField(text: $importText, axis: .vertical, label: { Text("")})
                            .lineLimit(10, reservesSpace: true)
                        
                        Button {
                            appController.importUploadList(fromXml: self.importText)
                            self.importText = ""
                        } label: {
                            Text("Import")
                        }
                    }
                }
                .padding()
            }
        }
    }
}
