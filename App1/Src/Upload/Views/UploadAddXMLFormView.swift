
import SwiftUI



struct UploadAddXMLFormView: View {
    
    
    @Environment(\.uploadStore)
    var uploadStore: UploadStoreProtocol!


    @State var importText: String = ""
    
    
    var body: some View {
            
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("XML import")
                Spacer()
                Text("􀈄")
            }
            .font(.title2)
            
            VStack(alignment: .leading) {
                
                TextField(text: $importText, axis: .vertical, label: { Text("")})
                    .lineLimit(10, reservesSpace: true)
                
                Button("Import") {
                    uploadStore.importUploadList(fromXml: self.importText)
                    self.importText = ""
                }
            }
        }
        .padding()
    }
}
