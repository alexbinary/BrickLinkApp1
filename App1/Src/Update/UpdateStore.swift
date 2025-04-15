
import Foundation



@Observable
@MainActor
public class UpdateStore {
    
    
    private let updateController: UpdateController
    
    
    init(_ updateController: UpdateController) {
        
        self.updateController = updateController
    }
    
    
    public func isLoadingOperations(withTag tag: OperationTag) -> Bool {
        
        updateController.isRunningOrIsScheduledToRun_operations(withTag: tag)
    }
}
