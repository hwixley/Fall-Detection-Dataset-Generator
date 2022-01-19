//
//  mnSettingsViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 25/08/2021.
//

import UIKit

class mnSettingsViewController: UIViewController, UITextFieldDelegate {

    //MARK: Textfields
    @IBOutlet weak var lengthTextfield: UITextField!
    @IBOutlet weak var fallTextfield: UITextField!
    @IBOutlet weak var ipTextfield: UITextField!
    @IBOutlet weak var portTextfield: UITextField!
    
    //MARK: Labels
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var fallLabel: UILabel!
    @IBOutlet weak var ipLabel: UILabel!
    @IBOutlet weak var portLabel: UILabel!
    
    //MARK: Input properties
    @IBOutlet var tapOutsideKB: UITapGestureRecognizer!
    
    //MARK: Temporary vars
    var clickedTextfield = UITextField()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lengthTextfield.text = ""
        self.fallTextfield.text = ""
        self.ipTextfield.text = ""
        self.portTextfield.text = ""
        self.lengthTextfield.placeholder = MyConstants.recordingLength == 15 ? "Default 15s" : "15s -> \(String(MyConstants.recordingLength))s"
        self.fallTextfield.placeholder = MyConstants.fallTime == 10 ? "Default 10s" : "10s -> \(String(MyConstants.fallTime))s"
        self.ipTextfield.placeholder = MyConstants.serverIP == "192.168.8.160" ? "Default: 192.168.8.160" : "-> \(MyConstants.serverIP)"
        self.portTextfield.placeholder = MyConstants.serverPort == "8081" ? "Default: 8081" : "8081 -> \(MyConstants.serverPort)"
        self.tapOutsideKB.isEnabled = false
        
        self.lengthTextfield.delegate = self
        self.fallTextfield.delegate = self
        self.ipTextfield.delegate = self
        self.portTextfield.delegate = self
    }
    
    //MARK: Actions
    @IBAction func updateRecordingLength(_ sender: UIButton) {
        self.clickedTextfield.resignFirstResponder()
        
        if lengthTextfield.text != nil && lengthTextfield.text! != "", let length = Double(lengthTextfield.text!) {
            if (length >= MyConstants.fallTime + 5) {
                MyConstants.recordingLength = length
            } else {
                self.lengthLabel.textColor = UIColor.red
            }
        } else {
            self.lengthLabel.textColor = UIColor.red
        }
        self.viewDidLoad()
    }
    
    @IBAction func updateFallTime(_ sender: Any) {
        self.clickedTextfield.resignFirstResponder()
        
        if fallTextfield.text != nil && fallTextfield.text! != "", let fallTime = Double(fallTextfield.text!) {
            if fallTime >= 10 && (fallTime <= MyConstants.recordingLength - 5) {
                MyConstants.fallTime = fallTime
            } else {
                fallLabel.textColor = UIColor.red
            }
        } else {
            fallLabel.textColor = UIColor.red
        }
        self.viewDidLoad()
    }
    
    @IBAction func updateIP(_ sender: UIButton) {
        self.clickedTextfield.resignFirstResponder()
        var sin = sockaddr_in()
        
        if ipTextfield.text != nil && ipTextfield.text! != "" && ipTextfield.text!.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
            MyConstants.serverIP = ipTextfield.text!
        } else {
            ipLabel.textColor = UIColor.red
        }
    }
    
    @IBAction func updatePort(_ sender: UIButton) {
        self.clickedTextfield.resignFirstResponder()
        
        if portTextfield.text != nil && portTextfield.text! != "" {
            MyConstants.serverPort = portTextfield.text!
        } else {
            portLabel.textColor = UIColor.red
        }
    }
    
    @IBAction func tapOutsideKB(_ sender: UITapGestureRecognizer) {
        self.clickedTextfield.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
    }
    
    //MARK: Textfield methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tapOutsideKB.isEnabled = true
        self.clickedTextfield = textField
    }
}
