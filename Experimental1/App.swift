
import SwiftUI



@main
struct Experimental1: App {
    
    
    @StateObject var controller = Controller()
    

    var body: some Scene {

        WindowGroup {
            ContentView1()
                .environmentObject(controller)
            ContentView2()
                .environmentObject(controller)
        }
    }
}



class Controller: ObservableObject {
    
    @Published var data1: String = "d1"
    @Published var data2: String = "d2"
    
    func mutate1() {
        data1 = "\(Date())"
    }
    
    func mutate2() {
        data2 = "\(Date())"
    }
}
