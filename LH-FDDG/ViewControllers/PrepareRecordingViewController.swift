//
//  PrepareRecordingViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 04/07/2021.
//

import UIKit
//import Firebase

class PrepareRecordingViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //MARK: Input properties
    @IBOutlet weak var placementTextfield: UITextField!
    @IBOutlet weak var subjectIdTextfield: UITextField!
    @IBOutlet var tapOutsideKB: UITapGestureRecognizer!
    
    //MARK: Labels
    @IBOutlet weak var placementLabel: UILabel!
    @IBOutlet weak var subjectIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Data
    //var recordingInfo: RecordingInfo? = nil
    var recording: Recording? = nil
    
    //MARK: Textfield Pickers
    var placementPicker = UIPickerView()
    
    //MARK: Temporary variables
    var clickedTxtf : UITextField? = nil
    var userFetched = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Picker setup
        self.placementPicker.delegate = self
        self.placementPicker.dataSource = self
        
        //Textfield setup
        self.placementTextfield.delegate = self
        self.placementTextfield.inputView = self.placementPicker
        self.subjectIdTextfield.delegate = self
        
        //General VC setup
        self.statusLabel.isHidden = true
        self.tapOutsideKB.isEnabled = false
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let nc = segue.destination as! UINavigationController
        let vc = nc.viewControllers.first as! RecordingViewController
        vc.buffer.postQueue = PostQueue(queue: [], meta: RecordingMeta(subject_id: MyConstants.user!.subject_id, phone_placement: self.placementTextfield.text!, recording_duration: -1, chunk_ids: []))
    }
    
    @IBAction func unwindToPrepareRecording(segue: UIStoryboardSegue) {
    }
    
    
    //MARK: Actions
    
    @IBAction func clickStartRecording(_ sender: UIButton) {
        if clickedTxtf != nil {
            self.clickedTxtf!.resignFirstResponder()
            self.tapOutsideKB.isEnabled = false
        }
        
        if self.validateInputs() {
            if MyConstants.user != nil && MyConstants.user!.subject_id == self.subjectIdTextfield.text! && MyConstants.user!._id != "" {
                self.performSegue(withIdentifier: "startRecording", sender: self)
            } else {
                self.subjectIdLabel.textColor = UIColor.orange
            }
        }
    }
    
    @IBAction func tapOutsideKB(_ sender: UITapGestureRecognizer) {
        self.clickedTxtf!.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
        
        if self.clickedTxtf! == self.subjectIdTextfield && subjectIdTextfield.text! != "" {
            APIFunctions.functions.fetchUser(subject_id: self.subjectIdTextfield.text!)
        }
    }
    
    //MARK: Picker View

     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return MyConstants.placements.count + 1
     }

     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.placementTextfield.text = row == 0 ? "" : MyConstants.placements[row-1]
     }

     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row == 0 ? "Select an option..." : MyConstants.placements[row-1]
     }
    
    
    //MARK: Textfields
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.clickedTxtf = textField
        self.tapOutsideKB.isEnabled = true
    }

    
    //MARK: Private methods
    
    func validateInputs() -> Bool {
        var isValid = true
        let errorTextColor = UIColor.systemPink
        let normalTextColor = UIColor.black
        
        self.placementLabel.textColor = normalTextColor
        self.subjectIdLabel.textColor = normalTextColor
        
        if self.placementTextfield.text == "" {
            self.placementLabel.textColor = errorTextColor
            isValid = false
        }
        if subjectIdTextfield.text == "" {
            self.subjectIdLabel.textColor = errorTextColor
            isValid = false
        }
        if !isValid {
            self.statusLabel.isHidden = false
            return false
        } else {
            
            self.statusLabel.isHidden = true
            
            recording = Recording(subject_id: self.subjectIdTextfield.text!, fall_time: MyConstants.fallTime, fall_type: "", recording_duration: MyConstants.recordingLength, ground_time: Double([2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)]), action: "", phone_placement: self.placementTextfield.text!, p_ecg: [], p_hr: [], p_contact: [], p_acc_x: [], p_acc_y: [], p_acc_z: [], acc_x: [], acc_y: [], acc_z: [], gyr_x: [], gyr_y: [], gyr_z: [], gra_x: [], gra_y: [], gra_z: [], mag_x: [], mag_y: [], mag_z: [], att_roll: [], att_pitch: [], att_yaw: [], delta_heading: [], timestamps: [])
            
            return true
        }
    }
    
}
