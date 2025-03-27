
import SwiftUI
import Core



struct ItemTypePicker: View {

    
    let label: String

    @Binding
    var selection: ItemType
    
    
    init(_ label: String, selection: Binding<ItemType>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(ItemType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
}



#Preview {
    @Previewable @State var selection: ItemType = .part
    ItemTypePicker("Type", selection: $selection)
}
