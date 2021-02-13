//
//  SelectorTableViewCell.swift
//  GyverLamp
//
//  Created by Максим Казачков on 01.12.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class SelectorTableViewCell: UITableViewCell {

    @IBOutlet weak var day: UILabel!
    
    @IBOutlet weak var selector: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
