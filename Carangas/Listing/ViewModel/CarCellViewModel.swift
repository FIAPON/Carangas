//
//  CarCellViewModel.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

struct CarCellViewModel {
    
    private var car: Car
    
    init(car: Car) {
        self.car = car
    }
    
    var name: String {
        car.name
    }
    
    var brand: String {
        car.brand
    }
    
}
