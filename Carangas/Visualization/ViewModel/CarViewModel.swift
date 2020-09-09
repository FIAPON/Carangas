//
//  CarViewModel.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

struct CarViewModel {
    
    private(set) var car: Car
    
    init(car: Car) {
        self.car = car
    }
    
    var title: String {
        return car.name
    }
    
    var brand: String {
        return "Marca: \(car.brand)"
    }
    
    var gasType: String {
        return "Combustível: \(car.gas)"
    }
    
    var price: String {
        let price = Formatter.currencyFormatter.string(from: NSNumber(value: car.price)) ?? "R$ \(car.price)"
        return "Preço: \(price)"
    }
}

