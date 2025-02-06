
import SwiftUI



@main
struct Experimental1: App {
    
    
    @State var controller = Controller()
    

    var body: some Scene {

        WindowGroup {
            ContentView1()
                .environment(controller)
            ContentView2()
                .environment(controller)
        }
    }
}



@Observable
class Controller {
    
    var data1: String = "d1"
    var data2: String = "d2"
    
    func mutate1() {
        data1 = "\(Date())"
    }
    
    func mutate2() {
        data2 = "\(Date())"
    }
}
