
import SwiftUI



struct LegoColorPicker: View {

    
    @Environment(Catalog.self)
    var catalog
    
    
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
            ForEach(colors) { Text($0.name).foregroundStyle($0.color).tag($0.id) }
        }
        .pickerStyle(.menu)
    }
}



#Preview {
    @Previewable @State var selection: LegoColor.ID = "11"
    
    let env = createEnv()
    
    LegoColorPicker("Color", selection: $selection)
        .inject(env)
}
