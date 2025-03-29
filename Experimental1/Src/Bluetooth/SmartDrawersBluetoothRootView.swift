
import SwiftUI



struct SmartDrawersBluetoothRootView: View {
    
    
    var controller = SmartDrawersBluetoothController()
    
    
    @State var drawer = ""

    
    var body: some View {

        VStack {
            
            Text(controller.state == .connecting ? "Connecting..." : "Ready")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .padding(.top, 8)
            Divider()
            
            Spacer()
            
            VStack {
                
                HStack {
                    Text(drawer).padding()
                    Spacer()
                    Button { submit() } label: { Text("Send").padding() }
                }
                
                KeyPad { drawer.append($0) }
            }
            .font(.title)
            .padding()
            .disabled(controller.state != .ready)
            
            Spacer()
        }
    }
    
    
    func submit() {
        
        controller.openDrawer(drawer)
    }
}



struct KeyPad: View {
    
    
    let onKey: (String) -> Void
    
    
    var body: some View {
        
        VStack {
            ForEach(0..<4) { y in
                HStack {
                    ForEach(0..<3) { x in
                        let n = y*3+x+1
                        if n < 10 {
                            button(n)
                        } else if n == 11 {
                            button(0)
                        }
                    }
                }
            }
        }
        .font(.title)
    }
    
    
    @ViewBuilder
    func button(_ key: Int) -> some View {
        
        let k = "\(key)"
        Button { onKey(k) } label: { Text(k).padding() }
    }
}



#Preview {
    SmartDrawersBluetoothRootView()
}
