//
//  StartViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 01/07/2021.
//

import UIKit

protocol DataDelegate {
    func fetchRecordings(recordings: String)
}

class StartViewController: UIViewController {
    
    var recordingsArray = [Recording]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getConstantData()
        
        APIFunctions.functions.delegate = self
        APIFunctions.functions.fetchRecordings()
        print(recordingsArray)
    }
    

    // MARK: - Navigation
    @IBAction func unwindToStart(segue: UIStoryboardSegue) {
    }

}


extension StartViewController: DataDelegate {
    
    func fetchRecordings(recordings: String) {
        do {
            recordingsArray = try JSONDecoder().decode([Recording].self, from: recordings.data(using: .utf8)!)
            print(recordingsArray)
        } catch {
            print("Failed to decode")
        }
    }
}
