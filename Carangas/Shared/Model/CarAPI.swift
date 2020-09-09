//
//  CarAPI.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import Foundation

enum APIError: Error {
    case badURL
    case taskError
    case badResponse
    case invalidStatusCode(Int)
    case noData
    case invalidJSON
}

enum RESTOperation: String {
    case update = "PUT"
    case create = "POST"
    case delete = "DELETE"
}

class CarAPI {
    
    private static let basePath = "https://carangas.herokuapp.com/cars"
    private static let configuration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = ["Content-Type": "application/json"]
        configuration.timeoutIntervalForRequest = 40
        configuration.allowsCellularAccess = true
        configuration.httpMaximumConnectionsPerHost = 6
        return configuration
    }()
    private static let session = URLSession(configuration: configuration)
    
    private init() {}
    
    static func loadCars(onComplete: @escaping (Result<[Car], APIError>)->Void) {
        guard let url = URL(string: basePath) else {
            onComplete(.failure(.badURL))
            return
        }
        let task = session.dataTask(with: url) { (data, response, error) in
            if let _ = error {
                onComplete(.failure(.taskError))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                onComplete(.failure(.badResponse))
                return
            }
            if response.statusCode != 200 {
                onComplete(.failure(.invalidStatusCode(response.statusCode)))
                return
            }
            guard let data = data else {
                onComplete(.failure(.noData))
                return
            }
            do {
                let cars = try JSONDecoder().decode([Car].self, from: data)
                onComplete(.success(cars))
            } catch {
                print(error)
                onComplete(.failure(.invalidJSON))
            }
        }
        task.resume()
    }
    
    static func updateCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>)->Void) {
        request(operation: .update, car: car, onComplete: onComplete)
    }
    static func deleteCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>)->Void) {
        request(operation: .delete, car: car, onComplete: onComplete)
    }
    static func createCar(_ car: Car, onComplete: @escaping (Result<Void, APIError>)->Void) {
        request(operation: .create, car: car, onComplete: onComplete)
    }
    
    private static func request(operation: RESTOperation, car: Car, onComplete: @escaping (Result<Void, APIError>)->Void) {
        let carID = car._id ?? ""
        guard let url = URL(string: "\(basePath)/\(carID)") else {
            onComplete(.failure(.badURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = operation.rawValue
        request.httpBody = try? JSONEncoder().encode(car)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let _ = error {
                return onComplete(.failure(.taskError))
            }
            guard let response = response as? HTTPURLResponse else {
                return onComplete(.failure(.badResponse))
            }
            if response.statusCode != 200 {
                return onComplete(.failure(.invalidStatusCode(response.statusCode)))
            }
            guard let _ = data else {
                return onComplete(.failure(.noData))
            }
            do {
                onComplete(.success(()))
            }
        }
        task.resume()
    }
    
    static func loadBrands(onComplete: @escaping (Result<[String], APIError>)->Void) {
        guard let url = URL(string: "http://fipeapi.appspot.com/api/1/carros/marcas.json") else {
            return onComplete(.failure(.badURL))
        }
        session.dataTask(with: url) { (data, _, _) in
            guard let data = data else {
                return onComplete(.failure(.noData))
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if let brands = try? decoder.decode([Brand].self, from: data) {
                let brandsStrings = brands.map({$0.fipeName})
                onComplete(.success(brandsStrings))
            } else {
                onComplete(.failure(.invalidJSON))
            }
        }.resume()
    }
}
