
import SwiftUI



struct AffranchissementTableRow: Identifiable {
    
    var id: Int { maxWeight }
    
    let minWeight: Int
    let maxWeight: Int
    
    let priceTimbre: Float
    let priceTracking: Float
    
    let tarifRef: Float
    
    let timbresParMultiples: Int?
    var timbresParMultiplesTotalPrice: Float? {
        guard let n = self.timbresParMultiples else { return nil }
        return Float(n) * priceTimbre + priceTracking
    }
    
    var nbTimbresRequired: Float {
        (self.tarifRef - priceTracking)/priceTimbre
    }
    var nbTimbresRequiredTotalPrice: Float {
        ceilf(nbTimbresRequired) * priceTimbre + priceTracking
    }
    
    var preferTimbresParMultiples: Bool {
        timbresParMultiplesTotalPrice != nil && timbresParMultiplesTotalPrice! <= tarifRef
    }
    var preferTimbres: Bool {
        nbTimbresRequiredTotalPrice <= tarifRef
    }
}


struct SelectedAffranchissement {
    
    let maxWeight: Int
    
    let useTimbresParMultiples: Bool
    let useTimbres: Bool
    let usePostOffice: Bool
    
    let nbTimbres: Int
}


let priceTimbreFrance: Float = 1.29
let priceTrackingFrance: Float = 0.50

let priceTimbreWorld: Float = 1.96
let priceTrackingWorld: Float = 2.80


let affranchissementValuesFrance = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 1.79, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 3.08, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 4.80, timbresParMultiples: 5
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 6.80, timbresParMultiples: 8
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.20, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 8.20, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreFrance,
        priceTracking: priceTrackingFrance,
        tarifRef: 9.79, timbresParMultiples: nil
    ),
]

let affranchissementValuesWorld = [

    AffranchissementTableRow(
        minWeight: 0, maxWeight: 20,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 4.76, timbresParMultiples: 1
    ),
    AffranchissementTableRow(
        minWeight: 20, maxWeight: 100,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 6.95, timbresParMultiples: 2
    ),
    AffranchissementTableRow(
        minWeight: 100, maxWeight: 250,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 12.65, timbresParMultiples: 5
    ),
    AffranchissementTableRow(
        minWeight: 250, maxWeight: 500,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 17.35, timbresParMultiples: 8
    ),
    AffranchissementTableRow(
        minWeight: 500, maxWeight: 750,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 29.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 750, maxWeight: 1000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 29.30, timbresParMultiples: nil
    ),
    AffranchissementTableRow(
        minWeight: 1000, maxWeight: 2000,
        priceTimbre: priceTimbreWorld,
        priceTracking: priceTrackingWorld,
        tarifRef: 29.30, timbresParMultiples: nil
    ),
]



struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<OrderDetails.ID>
    
    @State var orderItems: [OrderItem] = []
    
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                if selectedOrderIds.isEmpty {
                    
                    Text("select an order")
                    
                } else if orderItems.isEmpty {
                    
                    Text("loading order...")
                    
                } else {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        PickingItemsView(selectedOrderIds: selectedOrderIds, orderItems: orderItems)
                        
                        Divider()
                        
                        HeaderTitleView(label: "􁊇 Packing")
                        
                        if selectedOrderIds.count != 1 {
                            
                            Text("select only one order")
                            
                        } else if let order = appController.orderDetails(forOrderWithId: selectedOrderIds.first!) {
                            
                            Text("Address").font(.title2)
                            
                            Text(order.shippingAddressName)
                            Text(order.shippingAddress).fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode)
                            
                            Text("Shipping price").font(.title2)
                            
                            HStack {
                                Text(order.shippingCost, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                Text(" - \(order.shippingMethodName) \(String(format: "%.0f", order.totalWeight * orderWeightMarginRatio))g")
                            }
                            
                            ShippingCostView(order: order)
                            
                            Text("Affranchissement").font(.title2)
                            
                            HStack {
                                Text("Recommended method : ")
                                
                                let method = {
                                    
                                    var s = ""
                                    
                                    if let selectedAffranchissement = selectedAffranchissement {
                                        
                                        if selectedAffranchissement.usePostOffice {
                                            return "Bureau de poste"
                                        } else {
                                            s = "\(selectedAffranchissement.nbTimbres) timbres"
                                            
                                            if order.shippingMethodId != shippingMethodId_France {
                                                s += " international"
                                            }
                                            
                                            return s
                                        }
                                    }
                                    
                                    return s
                                }()
                                
                                Text(method)
                                
                                Button {
                                    appController.updateAffranchissement(forOrderWithId: order.id, method: method)
                                } label: {
                                    Text("Confirm affranchissement")
                                }
                                
                                Button {
                                    appController.updateAffranchissement(forOrderWithId: order.id, method: "Bureau de poste")
                                } label: {
                                    Text("Affranchissement Bureau de poste")
                                }
                                
                                if let confirmedMethod = appController.affranchissement(forOrderWithId: order.id) {
                                    
                                    HStack {
                                        Text("Confirmed")
                                        Text(confirmedMethod)
                                    }
                                }
                            }
                            
                            HStack {
                                Text("Timbre : ")
                                Text(order.shippingMethodId == shippingMethodId_France ? priceTimbreFrance : priceTimbreWorld, format: .currency(code: "EUR").presentation(.isoCode))
                            }
                            HStack {
                                Text("Suivi : ")
                                Text(order.shippingMethodId == shippingMethodId_France ? priceTrackingFrance : priceTrackingWorld, format: .currency(code: "EUR").presentation(.isoCode))
                            }
                            
                            Table(of: AffranchissementTableRow.self, selection: .constant(selectedAffranchissement?.maxWeight)) {
                                
                                TableColumn("Weight band") { item in
                                    Text("\(item.minWeight)-\(item.maxWeight)g")
                                }
                                
                                TableColumn("Timbres par multiples") { item in
                                    if let n = item.timbresParMultiples,
                                       let p = item.timbresParMultiplesTotalPrice {
                                        HStack {
                                            Text("\(n)   =>")
                                            Text(p, format: .currency(code: "EUR").presentation(.isoCode))
                                                .foregroundStyle(item.preferTimbresParMultiples ? green : red)
                                                .fontWeight(selectedAffranchissement?.maxWeight == item.maxWeight && selectedAffranchissement?.useTimbresParMultiples ?? false ? .bold : .regular)
                                        }
                                    }
                                }
                                
                                TableColumn("Tarif ref") { item in
                                    
                                    Text(item.tarifRef, format: .currency(code: "EUR").presentation(.isoCode))
                                        .foregroundStyle((!item.preferTimbresParMultiples && !item.preferTimbres) ? green : red)
                                        .fontWeight(selectedAffranchissement?.maxWeight == item.maxWeight && selectedAffranchissement?.usePostOffice ?? false ? .bold : .regular)
                                }
                                TableColumn("Nb timbres required") { item in
                                    HStack {
                                        Text("\(item.nbTimbresRequired)   =>")
                                        Text(item.nbTimbresRequiredTotalPrice, format: .currency(code: "EUR").presentation(.isoCode))
                                            .foregroundStyle(item.preferTimbres ? green : red)
                                            .fontWeight(selectedAffranchissement?.maxWeight == item.maxWeight && selectedAffranchissement?.useTimbres ?? false ? .bold : .regular)
                                    }
                                }
                                
                            } rows: {
                                
                                if order.shippingMethodId == shippingMethodId_France {
                                    
                                    ForEach(affranchissementValuesFrance) { item in
                                        TableRow(item)
                                    }
                                    
                                } else {
                                    
                                    ForEach(affranchissementValuesWorld) { item in
                                        TableRow(item)
                                    }
                                }
                            }
                            .frame(minHeight: 200)
                        }
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await parallel([
                    { await loadOrder() },
                    { await loadOrderItems() },
                ])
            }
            .onChange(of: selectedOrderIds) { oldValue, newValue in
                Task {
                    await parallel([
                        { await loadOrder() },
                        { await loadOrderItems() },
                    ])
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        if selectedOrderIds.count == 1 {
            await appController.loadOrderDetailsIfMissing(orderId: selectedOrderIds.first!)
        }
    }
    
    
    func loadOrderItems() async {
        
        self.orderItems.removeAll()
        
        for orderId in selectedOrderIds {
            self.orderItems.append(contentsOf: await appController.getOrderItems(orderId: orderId))
        }
    }
    
    
    var selectedAffranchissement: SelectedAffranchissement? {
        
        guard !selectedOrderIds.isEmpty,
              let order = appController.orderDetails(forOrderWithId: selectedOrderIds.first!)
        else {
            return nil
        }
        
        let weight = order.totalWeight * orderWeightMarginRatio
        
        if order.shippingMethodId == shippingMethodId_France {
            
            if let aff = affranchissementValuesFrance
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
            
        } else {
            
            if let aff = affranchissementValuesWorld
                .first(where: { Float($0.minWeight) <= weight && Float($0.maxWeight) >= weight }) {
                
                return SelectedAffranchissement(
                    maxWeight: aff.maxWeight,
                    
                    useTimbresParMultiples: aff.preferTimbresParMultiples,
                    useTimbres: aff.preferTimbres,
                    usePostOffice: !aff.preferTimbresParMultiples && !aff.preferTimbres,
                    
                    nbTimbres: aff.preferTimbres ? Int(ceil(aff.nbTimbresRequired)) : aff.preferTimbresParMultiples ? aff.timbresParMultiples ?? 0 : 0
                )
            }
        }
        
        return nil
    }
}
