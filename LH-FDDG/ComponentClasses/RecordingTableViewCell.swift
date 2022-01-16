//
//  RecordingTableViewCell.swift
//  FD-dataset-generator
//
//  Created by Harry Wixley on 10/07/2021.
//

import UIKit

class RecordingTableViewCell: UITableViewCell {

    //MARK: Properties
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var fallLabel: UILabel!
    @IBOutlet weak var numLabel: UILabel!
    @IBOutlet weak var completionView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
