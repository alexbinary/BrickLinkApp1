


protocol PartDescriptible {
    
    var partDescriptor: PartDescriptor { get }
}



struct PartDescriptor {
    
    var item_type: ItemType? = nil
    var item_ref: String? = nil
    var item_colorId: String? = nil
    var item_condition: ItemCondition? = nil
}

extension PartDescriptor: PartDescriptible {
    
    var partDescriptor: PartDescriptor { self }
}
