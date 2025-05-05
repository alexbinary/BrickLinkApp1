
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
            
            Text("NEW")
                .foregroundStyle(ItemCondition.new.color)
                .fontWeight(.bold)
                .tag(ItemCondition.new)
            Text("USED")
                .foregroundStyle(ItemCondition.used.color)
                .fontWeight(.bold)
                .tag(ItemCondition.used)
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
