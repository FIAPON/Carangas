//
//  CarsTableViewController.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import UIKit

class CarsTableViewController: UITableViewController {

    // MARK: - Properties
    var cars: [Car] = []
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl?.addTarget(self, action: #selector(loadCars), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCars()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let carViewController = segue.destination as? CarViewController,
           let carIndex = tableView.indexPathForSelectedRow?.row {
            carViewController.car = cars[carIndex]
        }
    }
    
    // MARK: - Methods
    @objc func loadCars() {
        CarAPI.loadCars { [weak self] (result) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
            switch result {
            case .success(let cars):
                self.cars = cars
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let apiError):
                print(apiError)
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let car = cars[indexPath.row]
        cell.textLabel?.text = car.name
        cell.detailTextLabel?.text = car.brand
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let car = cars[indexPath.row]
            CarAPI.deleteCar(car) { [weak self] (result) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.cars.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                    case .failure:
                        Alert.show(title: "Erro", message: "Não foi possível excluir o carro", presenter: self)
                    }
                }
            }
        }
    }
}
