
import SwiftUI



struct CheckStatusView: View {
    
    
    let status: Bool
    let mandatory: Bool
    
    
    init(status: Bool, mandatory: Bool = true) {
        self.status = status
        self.mandatory = mandatory
    }
    

    var body: some View {

        if status {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(mandatory ? red : .gray)
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
