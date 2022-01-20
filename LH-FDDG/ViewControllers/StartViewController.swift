//
//  StartViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 01/07/2021.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getConstantData()
    }
    

    // MARK: - Navigation
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
    }

}
