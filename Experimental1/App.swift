
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
    
    var store = Store()
    
    var data1: String { store.data1 }
    var data2: String { store.data2 }
    
    func read1() -> String {
        data1
    }
    
    func read2() -> String {
        data2
    }
    
    func mutate1() {
        store.mutate1()
    }
    
    func mutate2() {
        store.mutate2()
    }
}



@Observable
class Store {
    
    var data1: String = "d1"
    var data2: String = "d2"
    
    func mutate1() {
        data1 = "\(Date())"
    }
    
    func mutate2() {
        data2 = "\(Date())"
    }
}
