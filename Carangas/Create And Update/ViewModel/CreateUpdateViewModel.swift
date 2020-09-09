//
//  CreateUpdateViewModel.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

protocol CreateUpdateViewModelDelegate: class {
    func onBrandsLoaded(result: Result<Void, APIError>)
    func onCarCreated(result: Result<Void, APIError>)
    func onCarUpdated(result: Result<Void, APIError>)
}

class CreateUpdateViewModel {

    var car: Car
    var brands: [String] = []
    weak var delegate: CreateUpdateViewModelDelegate?

    init(car: Car? = nil) {
        self.car = car ?? Car()
    }
    
    var isEditing: Bool {
        return car._id != nil
    }
    
    var price: String {
        return Formatter.numberFormatter.string(from: NSNumber(value: car.price)) ?? "0,00"
    }

    var title: String {
        return isEditing ? "Edição" : "Cadastro"
    }

    var buttonTitle: String {
        return isEditing ? "Editar carro" : "Cadastrar carro"
    }

    var brand: String {
        return car.brand
    }

    var name: String {
        return car.name
    }

    var gasType: Int {
        return car.gasType
    }

    var brandsCount: Int {
        return brands.count
    }
    
    func getBrandAt(_ row: Int) -> String {
        return brands[row]
    }
    
    func save(name: String, brand: String, gasType: Int, price: String) {
        car.name = name
        car.brand = brand
        car.gasType = gasType
        car.price = Formatter.numberFormatter.number(from: price)?.doubleValue ?? 0
        
        if isEditing {
            CarAPI.updateCar(car) { [weak self] (result) in
                guard let self = self else {return}
                self.delegate?.onCarUpdated(result: result)
            }
        } else {
            CarAPI.createCar(car) { [weak self] (result) in
                guard let self = self else {return}
                self.delegate?.onCarCreated(result: result)
            }
        }
    }

    func loadBrands() {
        CarAPI.loadBrands { [weak self] (result) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let brands):
                    self.brands = brands
                    self.delegate?.onBrandsLoaded(result: .success(()))
                case .failure(let error):
                    self.delegate?.onBrandsLoaded(result: .failure(error))
                }
            }
        }
    }
}

