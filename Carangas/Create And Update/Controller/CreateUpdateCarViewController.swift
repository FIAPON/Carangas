//
//  CreateUpdateCarViewController.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import UIKit

class CreateUpdateCarViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var tfBrand: UITextField!
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfPrice: UITextField!
    @IBOutlet weak var scGasType: UISegmentedControl!
    @IBOutlet weak var btAddEdit: UIButton!
    
    // MARK: - Properties
    var car: Car!
    var brands: [String] = []
    lazy var pickerViewBrands: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
    }()
    let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.locale = Locale(identifier: "pt_BR")
        return numberFormatter
    }()
    
    // MARK: - Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        if car != nil {
            title = "Edição"
            btAddEdit.setTitle("Editar carro", for: .normal)
            tfBrand.text = car.brand
            tfName.text = car.name
            tfPrice.text = numberFormatter.string(from: NSNumber(value: car.price))
            scGasType.selectedSegmentIndex = car.gasType
        }
        setupBrands()
        loadBrands()
    }
    
    // MARK: - Methods
    func loadBrands() {
        CarAPI.loadBrands { [weak self] (result) in
            guard let self = self else {return}
            DispatchQueue.main.async {
                switch result {
                case .success(let brands):
                    self.brands = brands
                    self.pickerViewBrands.reloadAllComponents()
                case .failure:
                    Alert.show(title: "Erro", message: "Erro ao carregar as marcas", presenter: self)
                    self.tfBrand.inputAccessoryView = nil
                    self.tfBrand.inputView = nil
                }
            }
        }
    }

    func setupBrands() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        let btCancel = UIBarButtonItem(barButtonSystemItem: .cancel, target: view, action: #selector(UIView.endEditing))
        let btSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let btDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.items = [btCancel, btSpace, btDone]
        tfBrand.inputAccessoryView = toolbar
        tfBrand.inputView = pickerViewBrands
    }
    
    @objc func done() {
        tfBrand.text = brands[pickerViewBrands.selectedRow(inComponent: 0)]
        tfBrand.resignFirstResponder()
    }
    
    @IBAction func addEdit(_ sender: UIButton) {
        if car == nil {
            car = Car()
        }
        car.name = tfName.text!
        car.brand = tfBrand.text!
        car.gasType = scGasType.selectedSegmentIndex
        
        if let price = numberFormatter.number(from: tfPrice.text!)?.doubleValue {
            car.price = price
        } else {
            Alert.show(title: "Erro", message: "Por favor, preencha o valor somente com números, ponto e vírgula", presenter: self)
            return
        }
        
        if car._id == nil {
            CarAPI.createCar(car) { [weak self] (result) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.goBack()
                    case .failure:
                        Alert.show(title: "Erro", message: "Falha ao cadastrar o carro", presenter: self)
                    }
                }
            }
        } else {
            CarAPI.updateCar(car) { [weak self] (result) in
                guard let self = self else {return}
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.goBack()
                    case .failure:
                        Alert.show(title: "Erro", message: "Falha ao atualizar o carro", presenter: self)
                    }
                }
            }
        }
    }
    
    func goBack() {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UIPickerViewDelegate, UIPickerViewDataSource
extension CreateUpdateCarViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return brands.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return brands[row]
    }
}
