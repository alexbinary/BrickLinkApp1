
import SwiftUI



struct PaymentMethodPicker: View {
    
    
    let label: String

    @Binding
    var selection: PaymentMethod
    
    
    init(_ label: String, selection: Binding<PaymentMethod>) {
        self.label = label
        self._selection = selection
    }

    
    var body: some View {

        Picker(label, selection: $selection) {
            ForEach(PaymentMethod.allCases, id: \.self) { method in
                Text(method.rawValue).tag(method)
            }
        }
    }
}



#Preview {
    @Previewable @State var selection: PaymentMethod = .paypal
    PaymentMethodPicker("Payment method", selection: $selection)
}
