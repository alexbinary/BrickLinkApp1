
import SwiftUI



struct SmartDrawersBluetoothControlPanelView: View {
    
    
    var controller = SmartDrawersBluetoothController()
    var ready: Bool { controller.state == .ready }
    
    
    var body: some View {
            
        VStack {
            
            Text(controller.state == .connecting ? "Connecting..." : "Ready")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 48)
            Divider()
            
            Spacer()
            
            Button { openDrawer() }
            label: { Text("Open drawer").padding() }
                .disabled(!ready)
            
            Spacer()
        }
    }
    
    
    func openDrawer() {
        
        controller.openDrawer(1)
    }
}



#Preview {
    SmartDrawersBluetoothControlPanelView()
}
