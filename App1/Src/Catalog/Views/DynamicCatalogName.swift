
import SwiftUI



struct DynamicCatalogName: View {

    
    @Environment(Catalog.self)
    var catalog
    
    
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
    var catalogResult: Result<CatalogEntry>? = nil
    
    
    var body: some View {

        Group {
            if let result = catalogResult {
                
                switch result {
                    
                case .loading:
                    Text("Loading name from catalog...").foregroundStyle(.secondary)
                    
                case .found(let catalogEntry):
                    Text(catalogEntry.name).lineLimit(nil)
                    
                case .notFound:
                    Text("no catalog entry").foregroundStyle(.secondary)
                }
            }
        }
        .onChange(of: "\(type) \(ref)") { Task {
            
            catalogResult = .loading
            name = nil
            
            if let catalogEntry = await catalog.fetchEntry(forItemType: type, ref: ref) {
                
                catalogResult = .found(catalogEntry)
                name = catalogEntry.name
            } else {
                catalogResult = .notFound
            }
        } }
    }
}



#Preview {
    @Previewable @State var name: String? = ""
    
    let env = createEnv()
    
    DynamicCatalogName(forItemType: .part, ref: "3001", name: $name)
        .inject(env)
}
