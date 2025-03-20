
import SwiftUI



struct DynamicCatalogName: View {

    
    @Environment(CatalogController.self)
    var catalogController
    
    
    var type: BrickLinkItemType
    var ref: String
    
    @Binding
    var name: String?
    
    init(forItemType type: BrickLinkItemType, ref: String, name: Binding<String?>) {
        self.type = type
        self.ref = ref
        self._name = name
    }


    @State
    var catalogResult: Result<CatalogItem>? = nil
    
    
    var body: some View {

        Group {
            if let result = catalogResult {
                
                switch result {
                    
                case .loading:
                    Text("Loading name from catalog...").foregroundStyle(.secondary)
                    
                case .found(let catalogItem):
                    Text(catalogItem.name).lineLimit(nil)
                    
                case .notFound:
                    Text("no catalog entry").foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: "\(type) \(ref)") { Task {
            
            catalogResult = .loading
            name = nil
            
            if let catalogItem = await catalogController.getCatalogItem(forItemType: type, ref: ref) {
                
                catalogResult = .found(catalogItem)
                name = catalogItem.name
            } else {
                catalogResult = .notFound
            }
        } }
    }
}



#Preview {
    @Previewable @State var name: String? = ""
    
    let controllers = AppController.createControllers()
    let catalogController = controllers.catalogController
    
    DynamicCatalogName(forItemType: .part, ref: "3001", name: $name)
        .environment(catalogController)
}
