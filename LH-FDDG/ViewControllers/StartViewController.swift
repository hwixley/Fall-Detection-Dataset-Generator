//
//  StartViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 01/07/2021.
//

import UIKit

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
    
    func fetchUser(user: String) {
        do {
            let user = try JSONDecoder().decode(User.self, from: user.data(using: .utf8)!)
            print(user)
        } catch {
            print("Failed to decode /fetchUser response")
        }
    }
    
    func fetchRecordings(recordings: String) {
        do {
            recordingsArray = try JSONDecoder().decode([Recording].self, from: recordings.data(using: .utf8)!)
            print(recordingsArray)
        } catch {
            print("Failed to decode /fetchRecordings response")
        }
    }
}
