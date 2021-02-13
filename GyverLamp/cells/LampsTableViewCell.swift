//
//  LampsTableViewCell.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class LampsTableViewCell: UITableViewCell {

    
    @IBOutlet weak var lampLabel: UILabel!
    
    @IBOutlet weak var settingsButtonOut: UIButton!
    
    
    @IBOutlet weak var insertView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.insertView.backgroundColor = UIColor(red: 247.0 / 255.0, green: 247.0 / 255.0, blue: 247.0 / 255.0, alpha: 1)
        self.insertView.layer.cornerRadius = 14
        self.contentView.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
