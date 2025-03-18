
import SwiftUI



struct LegoColorPicker: View {

    
    @Environment(CatalogStore.self)
    var catalogStore
    
    
    let label: String

    @Binding
    var selection: LegoColor.ID
    
    
    init(_ label: String, selection: Binding<LegoColor.ID>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(catalogStore.allColors) { color in
                Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode)).tag(color.id)
            }
        }
        .pickerStyle(.menu)
    }
}



#Preview {
    @Previewable @State var selection: LegoColor.ID = "11"
    
    let appController = AppController()
    let catalogStore = appController.catalogStore
    
    LegoColorPicker("Color", selection: $selection)
        .environment(catalogStore)
}
