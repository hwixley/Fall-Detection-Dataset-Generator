//
//  ConnectViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 18/12/2021.
//

import UIKit
import SwiftUI

class ConnectViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Navigation
    
    @IBSegueAction func addSwiftUIView(_ coder: NSCoder) -> UIViewController? {
        return UIHostingController(coder: coder, rootView: PolarConnectionView(bleSdkManager: MyConstants.polarManager))
    }
    
}
