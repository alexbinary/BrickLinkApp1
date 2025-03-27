
import Foundation



@Observable
@MainActor
public class ShippingStore {
    
    
    private let shippingCoreController: ShippingCoreController
    private let orderCoreController: OrderCoreController
    
    
    init(
        _ shippingCoreController: ShippingCoreController,
        _ orderCoreController: OrderCoreController
    ) {
        self.shippingCoreController = shippingCoreController
        self.orderCoreController = orderCoreController
    }
    
    
    public func orderDetails(for order: Order) -> OrderDetails? {
        
        orderCoreController.orderDetails(for: order)
    }
    
    
    // MARK: - Shipping cost
    
    
    public func confirmedShippingCost(for order: Order) -> Float? {
        
        shippingCoreController.confirmedShippingCost(for: order)
    }
    
    
    public func confirmShippingCost(for order: Order, cost: Float) {
        
        shippingCoreController.confirmShippingCost(for: order, cost: cost)
    }
    
    
    public func selectedShippingCost(for order: Order) -> SelectedShippingCost? {
        
        let orderDetails = orderDetails(for: order)!
        
        let weight = orderDetails.totalWeight * orderWeightMarginRatio
        
        if orderDetails.shippingMethodId == shippingMethodId_France_LaPoste {
            
            if let band = shippingCostBandsFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                    
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if orderDetails.shippingMethodId == shippingMethodId_Europe_LaPoste {
            
            if let band = shippingCostBandsEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                  
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    chooseParcel = true
                    value = band.priceParcel
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
            
        } else if orderDetails.shippingMethodId == shippingMethodId_World_LaPoste {
            
            if let band = shippingCostBandsWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                    
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Decimal?
                
                if weight < 250 {
                    chooseLetter = true
                    value = band.letter?.bestPrice
                } else {
                    if ["US"].contains(orderDetails.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = band.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = band.priceParcelZB
                    }
                }
                
                var letterStamping: LetterStamping? = nil
                    
                if let priceLetter = band.letter {
                    
                    letterStamping = LetterStamping(
                        
                        useTimbresParMultiples: priceLetter.preferTimbresParMultiples,
                        useTimbres: priceLetter.preferCoverRefPriceWithTimbres,
                        usePostOffice: priceLetter.preferPostOffice,
                        nbTimbres: priceLetter.nbTimbres
                    )
                }
                
                return SelectedShippingCost(
                    maxWeight: band.maxWeight,
                    preferLetter: chooseLetter, preferParcel: chooseParcel,
                    preferParcelZB: chooseParcelZB, preferParcelZC: chooseParcelZC,
                    letterStamping: letterStamping,
                    value: value
                )
            }
            
            return nil
        }
        
        return nil
    }
    
    
    // MARK: - Stamping
    
    
    public func confirmedStamping(for order: Order) -> String? {
        
        shippingCoreController.confirmedStamping(for: order)
    }
    
    
    public func confirmStamping(for order: Order, stamping: String) {
        
        shippingCoreController.confirmStamping(for: order, stamping: stamping)
    }
    
    
    public func dateOrderValidatedWithoutStamping(_ order: Order) -> Date? {
        
        shippingCoreController.dateOrderValidatedWithoutStamping(order)
    }
    
    
    public func validateOrderWithoutStamping(_ order: Order) {
        
        shippingCoreController.validateOrderWithoutStamping(order)
    }
    
    
    public func recommendedStampingMethod(for order: Order) -> String {
        
        let selectedShippingCost = selectedShippingCost(for: order)
        let orderDetails = orderDetails(for: order)!
        
        var s = ""
        
        if let selectedLetterStamping = selectedShippingCost?.letterStamping {
            
            if selectedLetterStamping.usePostOffice {
                return "Bureau de poste"
            } else {
                s = "\(selectedLetterStamping.nbTimbres ?? 0) timbres"
                
                if orderDetails.shippingMethodId != shippingMethodId_France_LaPoste {
                    s += " international"
                }
                
                return s
            }
        }
        
        return s
    }
}
