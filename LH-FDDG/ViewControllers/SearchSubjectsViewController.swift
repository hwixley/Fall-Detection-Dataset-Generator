//
//  SearchSubjectsViewController.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 06/07/2021.
//

import UIKit
import FirebaseFirestore

class SearchSubjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    //MARK: Input properties
    @IBOutlet var tapOutsideKB: UITapGestureRecognizer!
    @IBOutlet weak var searchTextfield: UITextField!
    
    //MARK: Display properties
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Data
    var recordings = [RecordingInfo]()
    var subjectID = ""
    var selection : RecordingInfo? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //General setup
        self.loadCells(subjectID: self.subjectID)
        self.tableView.rowHeight = 90
        self.tapOutsideKB.isEnabled = false
        self.searchTextfield.text = subjectID
        
        //Table view setup
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Textfield setup
        self.searchTextfield.delegate = self
    }
    

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "startRecordingFromSearch" {
            let nc = segue.destination as! UINavigationController
            let vc = nc.viewControllers.first as! RecordingViewController
            self.selection!.subjectId = self.subjectID
            vc.recordingInfo = self.selection
            vc.segue = "unwindToSearchRecordings"
        }
    }
    
    @IBAction func unwindToSearchRecordings(segue: UIStoryboardSegue) {
    }
    
    //MARK: Actions
    @IBAction func tapSearch(_ sender: UIButton) {
        self.searchTextfield.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
        
        if Int(searchTextfield.text!) != nil || searchTextfield.text! == "" {
            self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            self.loadCells(subjectID: searchTextfield.text!)
            
            // Perform fetchUser request
        }
    }
    
    @IBAction func tapOutsideKB(_ sender: UITapGestureRecognizer) {
        self.searchTextfield.resignFirstResponder()
        self.tapOutsideKB.isEnabled = false
    }
    
    
    //MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.recordings.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.subjectID != "" {
            self.selection = self.recordings[indexPath.row]
            
            let ac = UIAlertController(title: "Do you want to make a new recording for this action?", message: "Action: " + self.selection!.action + ", Fall: " + (self.selection!.includesFall ? self.selection!.fallType : "none"), preferredStyle: UIAlertController.Style.alert)
            ac.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler: nil))
            ac.addAction(UIAlertAction(title: "Yes, start recording", style: UIAlertAction.Style.destructive, handler: { action in
                self.performSegue(withIdentifier: "startRecordingFromSearch", sender: self)
            }))
            self.present(ac, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RecordingTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RecordingTableViewCell else {
            fatalError("TableViewError: dequeued cell is not an instance RecordingTableViewCell")
        }
        
        let recording = recordings[indexPath.row]
        
        let actionTitle = NSMutableAttributedString(string: "Action: ", attributes: MyConstants.bold)
        let actionValue = NSAttributedString(string: recording.action, attributes: MyConstants.normal)
        actionTitle.append(actionValue)
        cell.actionLabel.attributedText = actionTitle
        
        let fallTitle = NSMutableAttributedString(string: "Fall: ", attributes: MyConstants.bold)
        let fallValue = NSAttributedString(string: recording.includesFall == true ? recording.fallType : "none", attributes: MyConstants.normal)
        fallTitle.append(fallValue)
        cell.fallLabel.attributedText = fallTitle
        
        let numTitle = NSMutableAttributedString(string: subjectID == "" ? "Total # recorded: " : "# recorded: ", attributes: MyConstants.bold)
        let numValue = NSAttributedString(string: String(recording.numberOfRecordings) + (subjectID == "" ? "" : "/" + String(MyConstants.goalRecordings)), attributes: MyConstants.normal)
        numTitle.append(numValue)
        cell.numLabel.attributedText = numTitle
        
        let percentage = Double(recording.numberOfRecordings)/Double(subjectID == "" ? MyConstants.goalRecordings*MyConstants.goalSubjects : MyConstants.goalRecordings)
        if percentage == 0 {
            cell.completionView.backgroundColor = MyConstants.colorGradient[0]
        } else if percentage == 1 {
            cell.completionView.backgroundColor = MyConstants.colorGradient[3]
        } else if percentage <= 0.5 {
            cell.completionView.backgroundColor = MyConstants.colorGradient[1]
        } else {
            cell.completionView.backgroundColor = MyConstants.colorGradient[2]
        }
        
        return cell
    }
    
    func loadCells(subjectID: String) {
        self.subjectID = subjectID
        
        if subjectID != "" {
            self.tableView.allowsSelection = true
            
            Firestore.firestore().collection("subjects").document(subjectID).collection("recordingStats").document("root").getDocument { docSnapshot, e in
                if e == nil && docSnapshot != nil && docSnapshot!.data() != nil {
                    self.recordings = []
                    
                    for rec in getSubjectStatsRecordings(subjectID: subjectID, docData: docSnapshot!.data()!) {
                        if !self.recordings.isEmpty {
                            for i in 0...(self.recordings.count-1) {
                                if rec.numberOfRecordings > self.recordings[i].numberOfRecordings && rec.numberOfRecordings < MyConstants.goalRecordings {
                                        self.recordings = self.recordings.prefix(i) + [rec] + self.recordings.suffix(self.recordings.count - i)
                                        break
                                } else if i == (self.recordings.count - 1) {
                                    self.recordings.append(rec)
                                    break
                                } else if rec.numberOfRecordings < self.recordings[i].numberOfRecordings && rec.numberOfRecordings >= MyConstants.goalRecordings {
                                    self.recordings = self.recordings.prefix(i) + [rec] + self.recordings.suffix(self.recordings.count - i)
                                    break
                                }
                            }
                        } else {
                            self.recordings.append(rec)
                        }
                    }
                    self.tableView.reloadData()
                    
                } else {
                    self.recordings = []
                    self.tableView.reloadData()
                }
            }
        } else {
            self.tableView.allowsSelection = false
            
            Firestore.firestore().collection("stats").document("root").addSnapshotListener({ docSnapshot, e in
                if e == nil && docSnapshot != nil {
                    self.recordings = []
                    
                    for rec in getSubjectStatsRecordings(subjectID: "", docData: docSnapshot!.data()!) {
                        if !self.recordings.isEmpty {
                            for i in 0...(self.recordings.count-1) {
                                if rec.numberOfRecordings > self.recordings[i].numberOfRecordings && rec.numberOfRecordings < MyConstants.goalRecordings {
                                        self.recordings = self.recordings.prefix(i) + [rec] + self.recordings.suffix(self.recordings.count - i)
                                        break
                                } else if i == (self.recordings.count - 1) {
                                    self.recordings.append(rec)
                                    break
                                } else if rec.numberOfRecordings < self.recordings[i].numberOfRecordings && rec.numberOfRecordings >= MyConstants.goalRecordings {
                                    self.recordings = self.recordings.prefix(i) + [rec] + self.recordings.suffix(self.recordings.count - i)
                                    break
                                }
                            }
                        } else {
                            self.recordings.append(rec)
                        }
                    }
                    self.tableView.reloadData()
                    
                } else {
                    self.navigationItem.prompt = "fuck"
                    print(e!.localizedDescription)
                }
            })
        }
    }
    
    //MARK: Textfield methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tapOutsideKB.isEnabled = true
    }
}
