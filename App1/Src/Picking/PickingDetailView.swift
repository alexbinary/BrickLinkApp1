
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


let shippingMethodId_France = 289751
let shippingMethodId_Europe = 290360
let shippingMethodId_World = 185519


struct PickingDetailView: View {
    
    
    @EnvironmentObject var appController: AppController
    
    let selectedOrderIds: Set<Order.ID>
    
    @State var order: Order? = nil
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
                            
                        } else if let order = order {
                            
                            Text("Address").font(.title2)
                            
                            Text(order.shippingAddressName ?? "")
                            Text(order.shippingAddress ?? "").fixedSize(horizontal: false, vertical: true)
                            Text(order.shippingAddressCountryCode ?? "")
                            
                            Text("Shipping price").font(.title2)
                            
                            HStack {
                                Text(order.shippingCost!, format: .currency(code: order.costCurrencyCode).presentation(.isoCode))
                                Text(" - \(order.shippingMethodName!) \(String(format: "%.0f", order.totalWeight!))g")
                            }
                            
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
                            
                            Table(of: ShippingCostTableRow.self) {
                                
                                TableColumn("Weight band") { item in
                                    Text("\(item.minWeight)-\(item.maxWeight)g")
                                }
                                TableColumn("Price letter with tracking") { item in
                                    if let price = item.priceLetter {
                                        Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                    }
                                }
                                
                                if order.shippingMethodId == shippingMethodId_World {
                                    
                                    TableColumn("Price parcel ZB") { item in
                                        if let price = item.priceParcelZB {
                                            Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        }
                                    }
                                    TableColumn("Price parcel ZC") { item in
                                        if let price = item.priceParcelZC {
                                            Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        }
                                    }
                                    
                                } else {
                                    
                                    TableColumn("Price parcel") { item in
                                        if let price = item.priceParcel {
                                            Text(price, format: .currency(code: "EUR").presentation(.isoCode))
                                        }
                                    }
                                }
                                
                            } rows: {
                                
                                if order.shippingMethodId == shippingMethodId_France {
                                    
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 0, maxWeight: 20,
                                        priceLetter: 1.79, priceParcel: 4.99
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 20, maxWeight: 100,
                                        priceLetter: 3.08, priceParcel: 4.99
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 100, maxWeight: 250,
                                        priceLetter: 4.80, priceParcel: 4.99
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 250, maxWeight: 500,
                                        priceLetter: 6.80, priceParcel: 6.99
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 500, maxWeight: 750,
                                        priceLetter: 8.20, priceParcel: 8.10
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 750, maxWeight: 1000,
                                        priceLetter: 8.20, priceParcel: 8.80
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 1000, maxWeight: 2000,
                                        priceLetter: 9.79, priceParcel: 10.15
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 2000, maxWeight: 5000,
                                        priceLetter: nil, priceParcel: 15.60
                                    ))
                                    
                                } else if order.shippingMethodId == shippingMethodId_Europe {
                                    
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 0, maxWeight: 20,
                                        priceLetter: 4.76, priceParcel: 14.25
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 20, maxWeight: 100,
                                        priceLetter: 6.95, priceParcel: 14.25
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 100, maxWeight: 250,
                                        priceLetter: 12.65, priceParcel: 14.25
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 250, maxWeight: 500,
                                        priceLetter: 17.35, priceParcel: 14.25
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 500, maxWeight: 750,
                                        priceLetter: 29.30, priceParcel: 17.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 750, maxWeight: 1000,
                                        priceLetter: 29.30, priceParcel: 17.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 1000, maxWeight: 2000,
                                        priceLetter: 29.30, priceParcel: 19.95
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 2000, maxWeight: 5000,
                                        priceLetter: nil, priceParcel: 25.50
                                    ))
                                    
                                } else if order.shippingMethodId == shippingMethodId_World {
                                    
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 0, maxWeight: 20,
                                        priceLetter: 4.76, priceParcelZB: 21.40, priceParcelZC: 31.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 20, maxWeight: 100,
                                        priceLetter: 6.95, priceParcelZB: 21.40, priceParcelZC: 31.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 100, maxWeight: 250,
                                        priceLetter: 12.65, priceParcelZB: 21.40, priceParcelZC: 31.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 250, maxWeight: 500,
                                        priceLetter: 17.35, priceParcelZB: 21.40, priceParcelZC: 31.60
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 500, maxWeight: 750,
                                        priceLetter: 29.30, priceParcelZB: 25.55, priceParcelZC: 35.15
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 750, maxWeight: 1000,
                                        priceLetter: 29.30, priceParcelZB: 25.55, priceParcelZC: 35.15
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 1000, maxWeight: 2000,
                                        priceLetter: 29.30, priceParcelZB: 27.95, priceParcelZC: 48.50
                                    ))
                                    TableRow(ShippingCostTableRow(
                                        minWeight: 2000, maxWeight: 5000,
                                        priceLetter: nil, priceParcelZB: 35.90, priceParcelZC: 70.80
                                    ))
                                }
                            }
                            .frame(minHeight: 250)
                        }
                        
                        Divider()
                        
                        Spacer()
                    }
                }
            }
            .padding()
            .task {
                await loadOrder()
                await loadOrderItems()
            }
            .onChange(of: selectedOrderIds) { oldValue, newValue in
                Task {
                    await loadOrder()
                    await loadOrderItems()
                }
            }
        }
    }
    
    
    func loadOrder() async {
        
        self.order = nil
        
        if selectedOrderIds.count == 1 {
            self.order = await appController.getOrder(orderId: selectedOrderIds.first!)
        }
    }
    
    
    func loadOrderItems() async {
        
        self.orderItems.removeAll()
        
        for orderId in selectedOrderIds {
            self.orderItems.append(contentsOf: await appController.getOrderItems(orderId: orderId))
        }
    }
}
