
import SwiftUI



struct PreviewUpdateStore: UpdateStoreProtocol {


    var isLoadingOperations: Bool {
        
        return false
    }
    
    func isLoadingOperations(withTag tag: OperationTag) -> Bool {
        
        return false
    }
}
