//
//  AddUserViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 06/07/2021.
//

import UIKit
import FirebaseFirestore

class AddUserViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Input properties
    @IBOutlet weak var nameTextfield: UITextField!
    @IBOutlet weak var ageTextfield: UITextField!
    @IBOutlet weak var heightTextfield: UITextField!
    @IBOutlet weak var weightTextfield: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var conditionsTextfield: UITextField!
    @IBOutlet var tapOutsideKB: UITapGestureRecognizer!
    
    //MARK: Labels
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var heightLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var conditionsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Temporary variables
    var clickedTxtf : UITextField? = nil
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Textfield setup
        self.nameTextfield.delegate = self
        self.ageTextfield.delegate = self
        self.heightTextfield.delegate = self
        self.weightTextfield.delegate = self
        self.conditionsTextfield.delegate = self

        //General setup
        self.tapOutsideKB.isEnabled = false
        self.statusLabel.isHidden = true
    }
    
    
    //MARK: Actions
    
    @IBAction func tapAddToDB(_ sender: UIButton) {
        if clickedTxtf != nil {
            self.clickedTxtf!.resignFirstResponder()
            self.tapOutsideKB.isEnabled = false
        }
        
        if validateInputs() {
            
            Firestore.firestore().collection("subjects").document("root").getDocument { docSnapshot, err in
                
                if err == nil && docSnapshot != nil {
                    let lastId = docSnapshot!.data()!["lastId"] as! Int
                    let newId = lastId + 1
                    
                    // Perform createUser request
                    MyConstants.user = User(_id: "", subject_id: String(newId), name: self.nameTextfield.text!, age: Int(self.ageTextfield.text!)!, height: Int(self.heightTextfield.text!)!, weight: Int(self.weightTextfield.text!)!, is_female: self.genderSegmentedControl.selectedSegmentIndex == 2 ? true : false, medical_conditions: self.conditionsTextfield.text!)
                    APIFunctions.functions.createUser(user: MyConstants.user!)
                    
                    /*Firestore.firestore().collection("subjects").document(String(newId)).setData(["id": String(newId)]/*, "name": self.nameTextfield.text!, "age": self.ageTextfield.text!, "height": self.heightTextfield.text!, "weight": self.weightTextfield.text!, "gender": self.genderSegmentedControl.selectedSegmentIndex == 1 ? "male" : "female", "medical_conditions": self.conditionsTextfield.text!]*/)
                    
                    Firestore.firestore().collection("subjects").document("root").updateData(["lastId": newId])
                    
                    Firestore.firestore().collection("subjects").document(String(newId)).collection("recordingStats").document("root").setData(getDefaultStats())*/
                    
                    let ac = UIAlertController(title: "Your subject ID is: " + String(newId), message: "Make sure to remember your number!", preferredStyle: UIAlertController.Style.alert)
                    ac.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    
                    self.ageTextfield.text = ""
                    self.nameTextfield.text = ""
                    self.heightTextfield.text = ""
                    self.weightTextfield.text = ""
                    self.genderSegmentedControl.selectedSegmentIndex = 0
                    self.conditionsTextfield.text = ""
                }
            }
        }
    }
    
    @IBAction func tapOutsideKB(_ sender: UITapGestureRecognizer) {
        self.clickedTxtf!.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
    }
    
    
    //MARK: Textfield methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clickedTxtf = textField
        self.tapOutsideKB.isEnabled = true
    }
    

    //MARK: Private methods
    
    func validateInputs() -> Bool {
        let normalColor = UIColor.black
        let errorColor = UIColor.systemPink
        var isValid = true
        
        self.nameLabel.textColor = normalColor
        self.ageLabel.textColor = normalColor
        self.heightLabel.textColor = normalColor
        self.weightLabel.textColor = normalColor
        self.genderLabel.textColor = normalColor
        self.conditionsLabel.textColor = normalColor
        
        if self.nameTextfield.text == "" {
            self.nameLabel.textColor = errorColor
            isValid = false
        }
        if self.ageTextfield.text == "" {
            self.ageLabel.textColor = errorColor
            isValid = false
        }
        if self.heightTextfield.text == "" {
            self.heightLabel.textColor = errorColor
            isValid = false
        }
        if self.weightTextfield.text == "" {
            self.weightLabel.textColor = errorColor
            isValid = false
        }
        if self.genderSegmentedControl.selectedSegmentIndex == 0 {
            self.genderLabel.textColor = errorColor
            isValid = false
        }
        if self.conditionsTextfield.text == "" {
            self.conditionsLabel.textColor = errorColor
            isValid = false
        }
        
        if !isValid {
            self.statusLabel.isHidden = false
            return false
        } else {
            self.statusLabel.isHidden = true
            return true
        }
    }
}
