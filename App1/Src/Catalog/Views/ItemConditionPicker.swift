
import SwiftUI



struct ItemConditionPicker: View {

    
    let label: String

    @Binding
    var selection: ItemCondition
    
    
    init(_ label: String, selection: Binding<ItemCondition>) {
        self.label = label
        self._selection = selection
    }
    
    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(ItemCondition.allCases, id: \.self) { condition in
                Text(condition.name.uppercased()).tag(condition)
            }
        }
    }
}



#Preview {
    
    @Previewable @State var selection: ItemCondition = .new
    
    VStack(alignment: .leading) {
        
        ItemConditionPicker("Type", selection: $selection)
        .padding()
        
        Text("Selected value: \(selection)").font(.title3)
        .padding()
    }
    .padding()
}
