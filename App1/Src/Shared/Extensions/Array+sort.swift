
import Foundation



/// ** Comparator **
///
/// Provides detailed comparison, that is relative order and equality.


enum ComparisonResult {
    
    case increasingOrder
    case decreasingOrder
    case equal
    
    var inverse: ComparisonResult {
        switch self {
        case .increasingOrder: .decreasingOrder
        case .decreasingOrder: .increasingOrder
        case .equal: .equal
        }
    }
}


protocol Comparator<T> {
    
    associatedtype T
    
    func compare(_ a: T, _ b: T) -> ComparisonResult
}


struct DefaultComparator<T: Comparable>: Comparator {
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        a == b ? .equal : a < b ? .increasingOrder : .decreasingOrder
    }
}


typealias ComparatorBlock<T> = (T, T) -> ComparisonResult

struct BlockComparator<T>: Comparator {
    
    let compareBlock: ComparatorBlock<T>
    
    init(_ compareBlock: @escaping ComparatorBlock<T>) {
        self.compareBlock = compareBlock
    }
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        compareBlock(a, b)
    }
}


struct FixedResultComparator<T>: Comparator {
    
    let result: ComparisonResult
    
    init(_ result: ComparisonResult = .equal) {
        self.result = result
    }
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        result
    }
}


struct UndefinedComparator<T>: Comparator {
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        .equal
    }
}


enum BoolOrdering {
    
    case true_before_false
    case true_after_false
}

struct BoolComparator: Comparator {
    
    let ordering: BoolOrdering
    
    init(_ ordering: BoolOrdering) {
        self.ordering = ordering
    }
    
    func compare(_ a: Bool, _ b: Bool) -> ComparisonResult {
        
        switch (a, b) {
            
        case (true, true):
            return .equal
        
        case (false, false):
            return.equal
            
        case (true, false):
            return ordering == .true_before_false ? .increasingOrder : .decreasingOrder
            
        case (false, true):
            return ordering == .true_after_false ? .increasingOrder : .decreasingOrder
        }
    }
}


struct ReversibleComparator<T>: Comparator {
    
    let baseComparator: any Comparator<T>
    let reverse: Bool
    
    init(
        _ baseComparator: any Comparator<T>,
        reverse: Bool = false
    ) {
        self.baseComparator = baseComparator
        self.reverse = reverse
    }
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        let res = baseComparator.compare(a, b)
        return reverse ? res.inverse : res
    }
}

extension ReversibleComparator where T: Comparable {
    
    init(
        _ baseComparator: any Comparator<T> = DefaultComparator(),
        reverse: Bool = false
    ) {
        self.baseComparator = baseComparator
        self.reverse = reverse
    }
}


struct CascadeComparator<T>: Comparator {
    
    let comparators: [any Comparator<T>]
    
    init(_ comparators: [any Comparator<T>]) {
        self.comparators = comparators
    }
    
    func compare(_ a: T, _ b: T) -> ComparisonResult {
        
        for comparator in comparators {
            let res = comparator.compare(a, b)
            if res != .equal {
                return res
            }
        }
        
        return .equal
    }
}


struct KeyPathComparator<Base, Value>: Comparator {
    
    let keypath: KeyPath<Base, Value>
    let valueComparator: any Comparator<Value>
    
    init(
        _ keypath: KeyPath<Base, Value>,
        _ valueComparator: any Comparator<Value>
    ) {
        self.keypath = keypath
        self.valueComparator = valueComparator
    }
    
    init(
        _ keypath: KeyPath<Base, Value>,
        _ valueComparatorBlock: @escaping ComparatorBlock<Value>
    ) {
        self.keypath = keypath
        self.valueComparator = BlockComparator(valueComparatorBlock)
    }
    
    func compare(_ a: Base, _ b: Base) -> ComparisonResult {
        
        let ta = a[keyPath: keypath]
        let tb = b[keyPath: keypath]
        
        return valueComparator.compare(ta, tb)
    }
}

extension KeyPathComparator where Value: Comparable {
    
    init(
        _ keypath: KeyPath<Base, Value>,
        _ valueComparator: any Comparator<Value> = DefaultComparator()
    ) {
        self.keypath = keypath
        self.valueComparator = valueComparator
    }
}

extension KeyPathComparator where Value == Bool {
    
    init(
        _ keypath: KeyPath<Base, Value>,
        _ boolOrdering: BoolOrdering
    ) {
        self.keypath = keypath
        self.valueComparator = BoolComparator(boolOrdering)
    }
}


struct TransformComparator<Base, Transformed>: Comparator {
    
    let transformer: (Base) -> Transformed
    let resultComparator: any Comparator<Transformed>
    
    func compare(_ a: Base, _ b: Base) -> ComparisonResult {
        
        let ta = transformer(a)
        let tb = transformer(b)
        
        return resultComparator.compare(ta, tb)
    }
}

extension TransformComparator where Transformed: Comparable {
    
    init(
        transformer: @escaping (Base) -> Transformed,
        resultComparator: any Comparator<Transformed> = DefaultComparator()
    ) {
        self.transformer = transformer
        self.resultComparator = resultComparator
    }
}


enum NilOrdering {
    
    case nil_before_some
    case nil_after_some
}


struct FailableTransformComparator<Base, Transformed>: Comparator {
    
    let transformer: (Base) -> Transformed?
    let resultComparator: any Comparator<Transformed>
    
    let nilOrdering: NilOrdering
    let comparatorWhenBothNil: any Comparator<Base>
    
    init(
        transformer: @escaping (Base) -> Transformed?,
        resultComparator: any Comparator<Transformed>,
        nilOrdering: NilOrdering,
        whenBothNil comparatorWhenBothNil: any Comparator<Base>
    ) {
        self.transformer = transformer
        self.resultComparator = resultComparator
        self.nilOrdering = nilOrdering
        self.comparatorWhenBothNil = comparatorWhenBothNil
    }
    
    func compare(_ a: Base, _ b: Base) -> ComparisonResult {
        
        let ta = transformer(a)
        let tb = transformer(b)
        
        switch (ta, tb) {
            
        case (nil, nil):
            return comparatorWhenBothNil.compare(a, b)
            
        case (.some(let wa), .some(let wb)):
            return resultComparator.compare(wa, wb)
        
        case (nil, .some):
            return nilOrdering == .nil_before_some ? .increasingOrder : .decreasingOrder
        
        case (.some, nil):
            return nilOrdering == .nil_after_some ? .increasingOrder : .decreasingOrder
        }
    }
}

extension FailableTransformComparator where Transformed: Comparable {
    
    init(
        transformer: @escaping (Base) -> Transformed?,
        resultComparator: any Comparator<Transformed> = DefaultComparator(),
        nilOrdering: NilOrdering,
        whenBothNil comparatorWhenBothNil: any Comparator<Base>
    ) {
        self.transformer = transformer
        self.resultComparator = resultComparator
        self.nilOrdering = nilOrdering
        self.comparatorWhenBothNil = comparatorWhenBothNil
    }
}



/// ** SortOrderEvaluator **
///
/// Provides an interface with Swift standard sort methods.
/// All sorting logic must eventually boil down to this.


protocol SortOrderEvaluator<T> {
    
    associatedtype T
    
    func areInIncreasingOrder(_ a: T, _ b: T) -> Bool
}


struct DefaultSortOrderEvaluator<T: Comparable>: SortOrderEvaluator {
    
    func areInIncreasingOrder(_ a: T, _ b: T) -> Bool {
        
        return a < b
    }
}


struct BlockSortOrderEvaluator<T>: SortOrderEvaluator {
    
    let evaluatorBlock: (T, T) -> Bool
    
    func areInIncreasingOrder(_ a: T, _ b: T) -> Bool {
        
        evaluatorBlock(a, b)
    }
}


struct ComparatorSortOrderEvaluator<T>: SortOrderEvaluator {
    
    let comparator: any Comparator<T>
    
    init(_ comparator: any Comparator<T>) {
        self.comparator = comparator
    }
    
    func areInIncreasingOrder(_ a: T, _ b: T) -> Bool {
        
        return comparator.compare(a, b) == .increasingOrder
    }
}



/// ** Array extensions **
///
/// Allows to use our custom *Comparator* and *OrderEvaluator* types


extension Array {
    
    
    /// ** Base functions to interface with our custom types **
    
    
    func sorted(using evaluator: any SortOrderEvaluator<Self.Element>) -> [Self.Element] {
        
        self.sorted(by: { evaluator.areInIncreasingOrder($0, $1) })
    }
    
    
    func sorted(using comparator: any Comparator<Self.Element>) -> [Self.Element] {
        
        self.sorted(using: ComparatorSortOrderEvaluator(comparator))
    }
    
    
    /// ** Convenience functions that take care of building and configuring comparators from simple parameters **
    
    
    func sorted(
    
        firstWith firstComparator: any Comparator<Self.Element>,
        thenWith secondComparator: any Comparator<Self.Element>
        
    ) -> [Self.Element] {
        
        self.sorted(using: CascadeComparator([firstComparator, secondComparator]))
    }
    
    
    func sorted<Transformed: Comparable>(
    
        firstOn keyPath: KeyPath<Self.Element, Bool>, _ boolOrdering: BoolOrdering,
        thenOn transformer: @escaping (Self.Element) -> Transformed?,
        
        sortNilFirst: Bool
        
    ) -> [Self.Element] {
        
        self.sorted(
            firstWith: KeyPathComparator(keyPath, boolOrdering),
            thenWith: FailableTransformComparator(
                transformer: transformer,
                nilOrdering: sortNilFirst ? .nil_before_some : .nil_after_some,
                whenBothNil: UndefinedComparator()
            )
        )
    }
    
    
    func sorted<Primary: Comparable, Fallback: Comparable>(
    
        tryUsing primaryTransformer: @escaping (Self.Element) -> Primary?,
        ifNilTry fallbackTransformer: @escaping (Self.Element) -> Fallback?,
        
        sortNilFirst: Bool
        
    ) -> [Self.Element] {
        
        self.sorted(using:
                            
            FailableTransformComparator(

                transformer: primaryTransformer,
                nilOrdering: sortNilFirst ? .nil_before_some : .nil_after_some,
                whenBothNil: FailableTransformComparator(
                
                    transformer: fallbackTransformer,
                    nilOrdering: sortNilFirst ? .nil_before_some : .nil_after_some,
                    whenBothNil: UndefinedComparator()
                )
            )
        )
    }
}
