
import SwiftUI



struct SmartDrawersBluetoothRootView: View {
    
    
    var controller = SmartDrawersBluetoothController()
    var ready: Bool { controller.state == .ready }
    
    
    @State var drawer = ""
    @State var history: [History] = []
    
    struct History: Identifiable {
        let id = UUID()
        let drawer: String
    }

    
    var body: some View {

        HSplitView {
            
            List() {
                Section {
                    ForEach(history.reversed()) { h in
                        
                        Text(h.drawer)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onTapGesture { send(h.drawer) }
                        .font(.title2)
                    }
                } header: {
                    Text("History").font(.title2).padding().frame(height: 48)
                }
            }
            .disabled(!ready)
            
            VStack {
                
                Text(controller.state == .connecting ? "Connecting..." : "Ready")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: 48)
                Divider()
                
                Spacer()
                
                VStack {
                    
                    HStack {
                        Text(drawer).padding()
                        Spacer()
                        Button { sendDrawer() }
                        label: { Text("Send").padding() }
                    }
                    
                    KeyPad { drawer.append($0) }
                }
                .font(.title)
                .padding()
                .disabled(!ready)
                
                Spacer()
            }
        }
    }
    
    
    func sendDrawer() {
        
        send(drawer)
        drawer = ""
    }
    
    
    func send(_ drawer: String) {
        
        controller.openDrawer(drawer)
        history.append(History(drawer: drawer))
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
