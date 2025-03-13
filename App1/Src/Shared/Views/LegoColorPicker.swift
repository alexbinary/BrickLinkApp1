
import SwiftUI



struct LegoColorPicker: View {

    
    @EnvironmentObject
    var app: AppController
    
    
    let label: String

    @Binding
    var selection: LegoColor.ID
    
    
    init(_ label: String, selection: Binding<LegoColor.ID>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(app.allColors) { color in
                Text(color.name).foregroundStyle(Color(fromBLCode: color.colorCode)).tag(color.id)
            }
        }
        .pickerStyle(.menu)
    }
}



#Preview {
    @Previewable @State var selection: LegoColor.ID = "11"
    LegoColorPicker("Color", selection: $selection)
}
