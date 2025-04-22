
import SwiftUI



struct ItemConditionPicker: View {

    
    let label: String

    @Binding
    var selection: String
    
    
    init(_ label: String, selection: Binding<String>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            Text("New").tag("N")
            Text("Used").tag("U")
        }
    }
}



#Preview {
    
    @Previewable @State var selection: String = "N"
    
    VStack(alignment: .leading) {
        
        ItemConditionPicker("Type", selection: $selection)
        .padding()
        
        Text("Selected value: \(selection)").font(.title3)
        .padding()
    }
    .padding()
}
