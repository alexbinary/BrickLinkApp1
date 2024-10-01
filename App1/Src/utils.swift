


func parallel(
    _ tasks: [@Sendable () async -> Void]
) async {
    
    await withTaskGroup(of: Void.self) { group in
        for task in tasks {
            group.addTask(operation: task)
        }
    }
}



extension Array {
    
    
    func limit(_ n: Int) -> Self {
        
        if self.isEmpty {
            return []
        }
        return Array(self[0...Swift.min(n - 1, self.count - 1)])
    }
}
