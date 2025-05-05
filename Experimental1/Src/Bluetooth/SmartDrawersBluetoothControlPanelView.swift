
import SwiftUI



struct SmartDrawersBluetoothControlPanelView: View {
    
    
    var controller = SmartDrawersBluetoothController()
    var ready: Bool { controller.state == .ready }
    
    @FocusState private var focused: Bool
    
    
    var body: some View {
            
        VStack {
            
            Text(controller.state == .connecting ? "Connecting..." : "Ready")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(ready ? .green : .orange)
            
            Spacer()
            
            Button { openDrawer() }
            label: { Text("Open drawer").padding() }
                .disabled(!ready)
                .focusable().focused($focused)
                .onAppear { focused = true }
                .onKeyPress(keys: [.space]) { press in
                    if !ready { return .ignored }
                    openDrawer()
                    return .handled
                }
            
            Spacer()
            
            HStack {
                Text("Repeat count: ").font(.title3)
                if let count = controller.repeatCount {
                    Text("\(count)").font(.title3)
                }
                Button { readRepeatCount() }
                label: { Text("􀅈") }
            }
            HStack {
                ForEach(1..<6) { count in
                    Button { setRepeatCount(UInt8(count)) }
                    label: { Text("\(count)").padding() }
                        
                }
            }
            .disabled(!ready)
            
            Spacer()
        }
        .onChange(of: ready, initial: true) {
            if ready {
                readRepeatCount()
            }
        }
    }
    
    
    func openDrawer() {
        
        controller.openDrawer(1)
    }
    
    
    func setRepeatCount(_ count: UInt8) {
        
        controller.setRepeatCount(count)
    }
    
    
    func readRepeatCount() {
     
        controller.readRepeatCount()
    }
}



#Preview {
    SmartDrawersBluetoothControlPanelView()
}
