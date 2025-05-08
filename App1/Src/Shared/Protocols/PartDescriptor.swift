


protocol PartDescriptible {
    
    var partDescriptor: PartDescriptor { get }
}



struct PartDescriptor {
    
    let type: ItemType?
    let ref: String?
    let comment: String?
    let colorId: String?
    let condition: ItemCondition?
    
    func withDefaults(
        
        type defaultType: ItemType? = nil,
        ref defaultRef: String? = nil,
        comment defaultComment: String? = nil,
        colorId defaultColorId: String? = nil,
        condition defaultCondition: ItemCondition? = nil
        
    ) -> PartDescriptor {
        
        .init(
            type: self.type ?? defaultType,
            ref: self.ref.withDefaultIfNilEmptyOrWhitespace(defaultRef),
            comment: self.comment.withDefaultIfNilEmptyOrWhitespace(defaultComment),
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
