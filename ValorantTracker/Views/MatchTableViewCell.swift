//
//  MatchTableViewCell.swift
//  ValorantTracker
//
//  Created by Aritro Paul on 05/01/21.
//

import UIKit

class MatchTableViewCell: UITableViewCell {

    @IBOutlet weak var pointDiffLabel: UILabel!
    @IBOutlet weak var mapNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
