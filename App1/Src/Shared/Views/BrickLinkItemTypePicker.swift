
import SwiftUI



struct BrickLinkItemTypePicker: View {

    
    let label: String

    @Binding
    var selection: BrickLinkItemType
    
    
    init(_ label: String, selection: Binding<BrickLinkItemType>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(BrickLinkItemType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
}



#Preview {
    @Previewable @State var selection: BrickLinkItemType = .part
    BrickLinkItemTypePicker("Type", selection: $selection)
}
