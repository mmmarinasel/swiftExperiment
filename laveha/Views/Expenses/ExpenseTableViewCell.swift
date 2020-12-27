//
//  ExpenseTableViewCell.swift
//  laveha
//
//  Created by Марина Селезнева on 02.12.2020.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var categLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
