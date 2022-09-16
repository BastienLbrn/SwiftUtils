//
//  VarExempleVMVC.swift
//  SwiftUtils
//
//  Created by Bastien Lebrun on 22/05/2022.
//

import UIKit

class ViewModel {

    private(set) var name: Variable<String> = Variable("")

}

class ViewController {

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self.viewModel.name.onUpdate = updateName // binding name update into ui label update
    }

    private func updateName(_ name: String) {
        nameLabel.text = name
    }
}
