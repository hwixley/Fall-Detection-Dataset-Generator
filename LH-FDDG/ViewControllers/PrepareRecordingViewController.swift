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
    @IBOutlet weak var actionTextfield: UITextField!
    @IBOutlet weak var includesFallSegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var fallTypeTextfield: UITextField!
    @IBOutlet weak var placementTextfield: UITextField!
    @IBOutlet weak var subjectIdTextfield: UITextField!
    @IBOutlet var tapOutsideKB: UITapGestureRecognizer!
    
    //MARK: Labels
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var includesFallLabel: UILabel!
    @IBOutlet weak var fallTypeLabel: UILabel!
    @IBOutlet weak var placementLabel: UILabel!
    @IBOutlet weak var subjectIdLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: Data
    //var recordingInfo: RecordingInfo? = nil
    var recording: Recording? = nil
    
    //MARK: Textfield Pickers
    var actionPicker = UIPickerView()
    var placementPicker = UIPickerView()
    var fallPicker = UIPickerView()
    
    //MARK: Temporary variables
    var clickedTxtf : UITextField? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Picker setup
        self.actionPicker.delegate = self
        self.actionPicker.dataSource = self
        self.placementPicker.delegate = self
        self.placementPicker.dataSource = self
        self.fallPicker.delegate = self
        self.fallPicker.dataSource = self
        
        //Textfield setup
        self.actionTextfield.delegate = self
        self.actionTextfield.inputView = self.actionPicker
        self.placementTextfield.delegate = self
        self.placementTextfield.inputView = self.placementPicker
        self.subjectIdTextfield.delegate = self
        self.fallTypeTextfield.delegate = self
        self.fallTypeTextfield.inputView = self.fallPicker
        
        //General VC setup
        self.fallTypeTextfield.isHidden = true
        self.fallTypeLabel.isHidden = true
        self.statusLabel.isHidden = true
        self.tapOutsideKB.isEnabled = false
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRecording" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! RecordingViewController
            //vc.recordingInfo = self.recordingInfo
            //vc.recording.subject_id = self.recordingInfo.
            vc.recording = self.recording!
            vc.segue = "unwindToPrepareRecording"
        }
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
            self.performSegue(withIdentifier: "startRecording", sender: self)
        }
    }
    
    @IBAction func tapOutsideKB(_ sender: UITapGestureRecognizer) {
        self.clickedTxtf!.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
    }
    
    @IBAction func changeIncludesFallSegment(_ sender: UISegmentedControl) {
        if self.includesFallSegmentedcontrol.selectedSegmentIndex == 1 {
            self.fallTypeLabel.isHidden = false
            self.fallTypeTextfield.isHidden = false
        } else {
            self.fallTypeLabel.isHidden = true
            self.fallTypeTextfield.isHidden = true
        }
    }
    
    //MARK: Picker View

     func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
     }

     func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView === self.actionPicker {
            return MyConstants.adls.count + 1
        } else if pickerView === self.placementPicker {
            return MyConstants.placements.count + 1
        } else {
            return MyConstants.falls.count + 1
        }
     }

     func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
         if pickerView === actionPicker {
            self.actionTextfield.text = row == 0 ? "" : MyConstants.adls[row-1]
         } else if pickerView === placementPicker {
            self.placementTextfield.text = row == 0 ? "" : MyConstants.placements[row-1]
         } else {
            self.fallTypeTextfield.text = row == 0 ? "" : MyConstants.falls[row-1]
         }
     }

     func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         if pickerView === actionPicker{
            return row == 0 ? "Select an option..." : MyConstants.adls[row-1]
         } else if pickerView === placementPicker {
            return row == 0 ? "Select an option..." : MyConstants.placements[row-1]
         } else {
            return row == 0 ? "Select an option..." : MyConstants.falls[row-1]
         }
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
        
        self.actionLabel.textColor = normalTextColor
        self.includesFallLabel.textColor = normalTextColor
        self.fallTypeLabel.textColor = normalTextColor
        self.placementLabel.textColor = normalTextColor
        self.subjectIdLabel.textColor = normalTextColor
        
        if self.actionTextfield.text == "" {
            self.actionLabel.textColor = errorTextColor
            isValid = false
        }
        if self.includesFallSegmentedcontrol.selectedSegmentIndex == 0 {
            self.includesFallLabel.textColor = errorTextColor
            isValid = false
        }
        if self.includesFallSegmentedcontrol.selectedSegmentIndex == 1 && self.fallTypeTextfield.text == "" {
            self.fallTypeLabel.textColor = errorTextColor
            isValid = false
        }
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
            
            recording = Recording(subject_id: self.subjectIdTextfield.text!, fall_time: MyConstants.fallTime, fall_type: self.fallTypeTextfield.text!, recording_duration: MyConstants.recordingLength, ground_time: Double([2,2,2,2,3,3,3,3,4,4,4,5,5,5,6,6,7,7,8][Int.random(in: 0...18)]), action: self.actionTextfield.text!, phone_placement: self.placementTextfield.text!, p_ecg: [], p_hr: [], p_contact: [], p_acc_x: [], p_acc_y: [], p_acc_z: [], acc_x: [], acc_y: [], acc_z: [], gyr_x: [], gyr_y: [], gyr_z: [], gra_x: [], gra_y: [], gra_z: [], mag_x: [], mag_y: [], mag_z: [], att_roll: [], att_pitch: [], att_yaw: [], delta_heading: [], timestamps: [])
            
            return true
        }
    }
    
}
