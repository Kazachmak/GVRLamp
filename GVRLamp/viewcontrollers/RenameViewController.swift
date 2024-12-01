//
//  RenameViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 03.12.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class RenameViewController: UIViewController {
    var lamp: LampDevice?

    @IBOutlet var textField: UITextField!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBAction func renameLamp(_ sender: UIButton) {
        if let name = textField.text {
            if let currentLamp = lamp {
                lamps.renameLamp(name: name, lamp: currentLamp)
            }
            dismiss(animated: true)
        }
    }

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBOutlet var renameLampOut: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        renameLampOut.imageView?.contentMode = .scaleAspectFit
        textField.setLeftPaddingPoints(20.0)
        textField.placeholder = lamp?.name
    }
}
