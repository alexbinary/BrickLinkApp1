
import SwiftUI



struct DynamicCatalogName: View {

    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    var type: ItemType
    var ref: String
    
    @Binding
    var name: String?
    
    init(forItemType type: ItemType, ref: String, name: Binding<String?>) {
        self.type = type
        self.ref = ref
        self._name = name
    }


    @State
    var catalogResult: Result<CatalogEntry>? = nil
    
    
    var body: some View {

        VStack {
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
        .onChange(of: "\(type) \(ref)", initial: true) { Task {
            
            catalogResult = .loading
            name = nil
            
            if let catalogEntry = await catalog.fetchEntry(forItemType: type, ref: ref) {
                
                catalogResult = .found(catalogEntry)
                name = catalogEntry.name
            } else {
                catalogResult = .notFound
            }
        }}
    }
}



#Preview {
    
    @Previewable @State var name: String? = ""
    
    VStack(alignment: .leading) {
        
        VStack(alignment: .leading) {
            Text("Catalog").font(.title3)
            DynamicCatalogName(forItemType: .part, ref: "", name: $name)
                .previewEnv(
                    catalog: PreviewCatalog(
                        catalogEntry: CatalogEntry(name: "entry name"),
                        catalogEntryLoadingDelay: 2
                    )
                )
        }
        .padding()
        
        VStack(alignment: .leading) {
            Text("Name binding").font(.title3)
            Text(name ?? "-")
        }
        .padding()
    }
    .padding()
}
