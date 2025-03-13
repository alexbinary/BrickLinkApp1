
import SwiftUI



struct UploadAddView: View {
    
    
    @EnvironmentObject var app: AppController

    @State var type: BrickLinkItemType = .part
    @State var ref: String = ""
    @State var colorId: LegoColor.ID = ""
    @State var qty: Int = 1
    @State var condition: String = "U"
    @State var comment: String = ""
    @State var unitPrice: Float = 0
    @State var importText: String = ""
    
    @State var catalogResult: Result<CatalogItem>? = nil
    
    
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
                            
                            if let catalogResult = catalogResult {
                                
                                switch catalogResult {
                                    
                                case .loading:
                                    Text("Loading name from catalog...").foregroundStyle(.secondary)
                                    
                                case .found(let catalogItem):
                                    Text(catalogItem.name).lineLimit(nil)
                                    
                                case .notFound:
                                    Text("no catalog entry").foregroundStyle(.secondary)
                                }
                            }
                            
                            Picker("Color", selection: $colorId) {
                                
                                ForEach(app.allColors) { color in
                                    
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
                            
                            let name: String? = {
                                
                                if let catalogResult = catalogResult {
                                    
                                    switch catalogResult {
                                        
                                    case .found(let catalogItem):
                                        return catalogItem.name
                                        
                                    default:
                                        break
                                    }
                                }
                                
                                return nil
                            }()
                            
                            Button {
                                app.addUploadItem(UploadItem(
                                    type: type,
                                    ref: ref,
                                    name: name,
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
                            
                        CatalogImage(itemType: type, ref: ref, colorId: colorId)
                    }
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    
                    HeaderTitleView(label: "􀈄 XML import")
                    
                    VStack(alignment: .leading) {
                        
                        TextField(text: $importText, axis: .vertical, label: { Text("")})
                            .lineLimit(10, reservesSpace: true)
                        
                        Button {
                            app.importUploadList(fromXml: self.importText)
                            self.importText = ""
                        } label: {
                            Text("Import")
                        }
                    }
                }
                .padding()
            }
        }
        .onChange(of: ref) {
            Task { await pullCatalogEntry() }
        }
    }
    
    
    func pullCatalogEntry() async {
        
        self.catalogResult = .loading
        
        if let catalog = await app.getCatalogItem(forItemType: type, ref: ref) {
            
            self.catalogResult = .found(catalog)
        } else {
            self.catalogResult = .notFound
        }
    }
}
