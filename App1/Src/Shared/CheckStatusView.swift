
import SwiftUI



struct CheckStatusView: View {
    
    
    let status: Bool
    

    var body: some View {

        if status {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(red)
        }
    }
}



#Preview {
    VStack {
        Group {
            CheckStatusView(status: true)
            CheckStatusView(status: false)
        }.padding()
    }
}
