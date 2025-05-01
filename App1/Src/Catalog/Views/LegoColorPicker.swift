
import SwiftUI



struct LegoColorPicker: View {

    
    @Environment(\.catalog)
    var catalog: CatalogProtocol!
    
    
    let label: String

    @Binding
    var selection: LegoColor.ID
    
    
    init(_ label: String, selection: Binding<LegoColor.ID>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        let colors = catalog.allColors
        
        Picker(label, selection: $selection) {
            ForEach(colors) { color in
             
                let text = {
                    var text = AttributedString("􀂓 \(color.name)")
                    if let range = text.range(of: "􀂓") {
                        text[range].foregroundColor = color.color
                    }
                    return text
                }()
                
                Text(text).tag(color.id)
            }
        }
        .pickerStyle(.menu)
    }
}



#Preview {
    
    @Previewable @State var selection: LegoColor.ID = ""
    
    VStack(alignment: .leading) {
        
        LegoColorPicker("Color", selection: $selection)
        .padding()
        
        Text("Selected value: \(selection)").font(.title3)
        .padding()
    }
    .padding()
    .previewEnv()
}
