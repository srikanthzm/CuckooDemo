//
//  ViewController.swift
//  Demo
//
//  Created by Srikanth Thangavel on 28/05/21.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    
    let viewModel = UserViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.accessibilityIdentifier = "name-label"
        
        viewModel.getData { (user) in
            DispatchQueue.main.async { [weak self] in
                self?.nameLabel.text = user?.name
            }
        }
    }

}

