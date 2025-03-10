


func parallel(
    _ tasks: [@MainActor () async -> Void]
) async {
    
    await withTaskGroup(of: Void.self) { group in
        for task in tasks {
            group.addTask(operation: task)
        }
    }
}
