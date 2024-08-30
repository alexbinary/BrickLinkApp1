
import SwiftUI



struct ShippingCostTableRow: Identifiable {
    
    var id: Int { maxWeight }
    let minWeight: Int
    let maxWeight: Int
    let priceLetter: Float?
    var priceParcel: Float? = nil
    var priceParcelZB: Float? = nil
    var priceParcelZC: Float? = nil
}


struct SelectedShippingCost {
    
    let maxWeight: Int
    var chooseLetter: Bool = false
    var chooseParcel: Bool = false
    var chooseParcelZB: Bool = false
    var chooseParcelZC: Bool = false
    let value: Float?
}



let shippingMethodId_France = 289751
let shippingMethodId_Europe = 290360
let shippingMethodId_World = 185519


let shippingCostFrance = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 1.79, priceParcel: 4.99
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 3.08, priceParcel: 4.99
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 4.80, priceParcel: 4.99
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 6.80, priceParcel: 6.99
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 8.20, priceParcel: 8.10
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 8.20, priceParcel: 8.80
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 9.79, priceParcel: 10.15
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 15.60
    ),
]

let shippingCostEurope = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.76, priceParcel: 14.25
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 6.95, priceParcel: 14.25
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 12.65, priceParcel: 14.25
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 17.35, priceParcel: 14.25
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 29.30, priceParcel: 17.60
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 29.30, priceParcel: 17.60
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 29.30, priceParcel: 19.95
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcel: 25.50
    ),
]

let shippingCostWorld = [
    
    ShippingCostTableRow(
        minWeight: 0, maxWeight: 20,
        priceLetter: 4.76, priceParcelZB: 21.40, priceParcelZC: 31.60
    ),
    ShippingCostTableRow(
        minWeight: 20, maxWeight: 100,
        priceLetter: 6.95, priceParcelZB: 21.40, priceParcelZC: 31.60
    ),
    ShippingCostTableRow(
        minWeight: 100, maxWeight: 250,
        priceLetter: 12.65, priceParcelZB: 21.40, priceParcelZC: 31.60
    ),
    ShippingCostTableRow(
        minWeight: 250, maxWeight: 500,
        priceLetter: 17.35, priceParcelZB: 21.40, priceParcelZC: 31.60
    ),
    ShippingCostTableRow(
        minWeight: 500, maxWeight: 750,
        priceLetter: 29.30, priceParcelZB: 25.55, priceParcelZC: 35.15
    ),
    ShippingCostTableRow(
        minWeight: 750, maxWeight: 1000,
        priceLetter: 29.30, priceParcelZB: 25.55, priceParcelZC: 35.15
    ),
    ShippingCostTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceLetter: 29.30, priceParcelZB: 27.95, priceParcelZC: 48.50
    ),
    ShippingCostTableRow(
        minWeight: 2000, maxWeight: 5000,
        priceLetter: nil, priceParcelZB: 35.90, priceParcelZC: 70.80
    ),
]



struct ShippingCostView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let order: Order
    
    
    var body: some View {
        
        Text("Shipping cost").font(.title2)
        
        HStack {
            Text("Tarifs La Poste 2024 - ")
            
            if order.shippingMethodId == shippingMethodId_France {
                Text("France")
            } else if order.shippingMethodId == shippingMethodId_Europe {
                Text("Europe")
            } else if order.shippingMethodId == shippingMethodId_World {
                Text("Monde")
            }
        }
        
        HStack {
            Text("Estimated shipping cost : ")
            
            if let selectedShippingCost = selectedShippingCost,
               let value = selectedShippingCost.value {
                
                Text(value, format: .currency(code: "EUR").presentation(.isoCode))
                
                Button {
                    appController.updateShippingCost(forOrderWithId: order.id, cost: value)
                } label: {
                    Text("Confirm shipping cost")
                }
            }
        }
        
        Table(of: ShippingCostTableRow.self, selection: .constant(selectedShippingCost?.maxWeight)) {
            
            TableColumn("Weight band") { item in
                Text("\(item.minWeight)-\(item.maxWeight)g")
            }
            TableColumn("Price letter with tracking") { item in
                if let price = item.priceLetter {
                    Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                        .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseLetter ?? false ? .bold : .regular)
                }
            }
            
            if order.shippingMethodId == shippingMethodId_World {
                
                TableColumn("Price parcel ZB*") { item in
                    if let price = item.priceParcelZB {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZB ?? false ? .bold : .regular)
                    }
                }
                TableColumn("Price parcel ZC*") { item in
                    if let price = item.priceParcelZC {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcelZC ?? false ? .bold : .regular)
                    }
                }
                
            } else {
                
                TableColumn("Price parcel") { item in
                    if let price = item.priceParcel {
                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                            .fontWeight(selectedShippingCost?.maxWeight == item.maxWeight && selectedShippingCost?.chooseParcel ?? false ? .bold : .regular)
                    }
                }
            }
            
        } rows: {
            
            if order.shippingMethodId == shippingMethodId_France {
                
                ForEach(shippingCostFrance) { item in
                    TableRow(item)
                }
                
            } else if order.shippingMethodId == shippingMethodId_Europe {
                
                ForEach(shippingCostEurope) { item in
                    TableRow(item)
                }
                
            } else if order.shippingMethodId == shippingMethodId_World {
                
                ForEach(shippingCostWorld) { item in
                    TableRow(item)
                }
            }
        }
        .frame(minHeight: 250)
        
        if order.shippingMethodId == shippingMethodId_World {
            
            Text("""
                                    *Zone B : Europe de l'Est (hors UE et Russie), Norvège, Maghreb
                                    *Zone C : Autres destinations
                                """).font(.footnote)
        }
        
    }
    
    
    var selectedShippingCost: SelectedShippingCost? {
        
        guard let weight = order.totalWeight else { return nil }
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let cost = shippingCostFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_Europe {
            
            if let cost = shippingCostEurope
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                var chooseParcel: Bool = false
                let chooseParcelZB: Bool = false
                let chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    chooseParcel = true
                    value = cost.priceParcel
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
            
        } else if order.shippingMethodId == shippingMethodId_World {
            
            if let cost = shippingCostWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                var chooseLetter: Bool = false
                let chooseParcel: Bool = false
                var chooseParcelZB: Bool = false
                var chooseParcelZC: Bool = false
                
                var value: Float?
                
                if weight < 250 {
                    chooseLetter = true
                    value = cost.priceLetter
                } else {
                    if ["US"].contains(order.shippingAddressCountryCode) {
                        chooseParcelZC = true
                        value = cost.priceParcelZC
                    } else {
                        chooseParcelZB = true
                        value = cost.priceParcelZB
                    }
                }
                
                return SelectedShippingCost(
                    maxWeight: cost.maxWeight,
                    chooseLetter: chooseLetter, chooseParcel: chooseParcel,
                    chooseParcelZB: chooseParcelZB, chooseParcelZC: chooseParcelZC,
                    value: value
                )
            }
        }
        
        return nil
    }
}
