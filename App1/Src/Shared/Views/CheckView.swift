import SwiftUI
import Core



struct CheckView: View {
    
    
    let state: ChecklistState
    let mandatory: Bool
    
    
    init(state: ChecklistState, mandatory: Bool = true) {
        self.state = state
        self.mandatory = mandatory
    }
    

    var body: some View {
        
        switch state {
        
        case .validated:
            Text("􀁣").foregroundStyle(green)
        
        case .pending:
            Text("􀀀").foregroundStyle(mandatory ? red : .gray)
        
        case .notApplicable:
            Text("􀀁").foregroundStyle(.gray)
        }
    }
}



#Preview {
    VStack {
        Group {
            CheckView(state: .validated)
            CheckView(state: .pending)
            CheckView(state: .pending, mandatory: false)
            CheckView(state: .notApplicable)
        }.padding()
    }
}
