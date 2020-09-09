//
//  CarTableViewCell.swift
//  Carangas
//
//  Copyright © 2020 Eric Brito. All rights reserved.
//

import UIKit

class CarTableViewCell: UITableViewCell {

    func configure(with viewModel: CarCellViewModel) {
        textLabel?.text = viewModel.name
        detailTextLabel?.text = viewModel.brand
    }

}
