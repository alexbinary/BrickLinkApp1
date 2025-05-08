


protocol PartDescriptible {
    
    var partDescriptor: PartDescriptor { get }
}



struct PartDescriptor {
    
    var type: ItemType? = nil
    var ref: String? = nil
    var colorId: String? = nil
    var condition: ItemCondition? = nil
}

extension PartDescriptor: PartDescriptible {
    
    var partDescriptor: PartDescriptor { self }
}
