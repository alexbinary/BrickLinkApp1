
import Foundation



@Observable
class UpdateStore {
    
    
    private let updateController: UpdateController
    
    
    init(_ updateController: UpdateController) {
        
        self.updateController = updateController
    }
    
    
    func isLoadingOperations(withTag tag: OperationTag) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_operations(withTag: tag)
    }
}
