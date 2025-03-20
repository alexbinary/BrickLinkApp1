
import SwiftUI



struct CheckView: View {
    
    
    let checked: Bool
    let mandatory: Bool
    
    
    init(checked: Bool, mandatory: Bool = true) {
        self.checked = checked
        self.mandatory = mandatory
    }
    

    var body: some View {

        if checked {
            Text("􀁣").foregroundStyle(green)
        } else {
            Text("􀀀").foregroundStyle(mandatory ? red : .gray)
        }
    }
}



#Preview {
    VStack {
        Group {
            CheckView(checked: true)
            CheckView(checked: false)
        }.padding()
    }
}
