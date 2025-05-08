


protocol PartDescriptible {
    
    var partDescriptor: PartDescriptor { get }
}



struct PartDescriptor {
    
    var type: ItemType? = nil
    var ref: String? = nil
    var colorId: String? = nil
    var condition: ItemCondition? = nil
    
    func withDefaults(
        
        type defaultType: ItemType? = nil,
        ref defaultRef: String? = nil,
        colorId defaultColorId: String? = nil,
        condition defaultCondition: ItemCondition? = nil
        
    ) -> PartDescriptor {
        
        .init(
            type: self.type ?? defaultType,
            ref: self.ref.withDefaultIfNilEmptyOrWhitespace(defaultRef),
            colorId: self.colorId.withDefaultIfNilEmptyOrWhitespace(defaultColorId),
            condition: self.condition ?? defaultCondition
        )
    }
}

extension PartDescriptor: PartDescriptible {
    
    var partDescriptor: PartDescriptor { self }
}



extension String? {
    
    var isNilEmptyOrWhitespace: Bool {
        
        self?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }
    
    func withDefaultIfNilEmptyOrWhitespace(_ def: String?) -> String? {
        
        self.isNilEmptyOrWhitespace ? def : self
    }
}
