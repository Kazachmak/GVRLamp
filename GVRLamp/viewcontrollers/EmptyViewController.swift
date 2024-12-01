//
//  EmptyViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 29.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit
import MIBlurPopup

class EmptyViewController: UIViewController {

    var lamp: LampDevice?

    var command: CommandsToLamp?

    @IBOutlet weak var containerView: UIView!

    @IBOutlet var mainView: UIView!

    var customBlurEffectStyle: UIBlurEffect.Style?
    var customInitialScaleAmmount: CGFloat!
    var customAnimationDuration: TimeInterval!

    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = children.last as! SliderFullScreenViewController
        if let currentLamp = lamp, let currentCommand = command {
            vc.setLamp(lamp: currentLamp, command: currentCommand)
        }

    }

}

extension EmptyViewController: MIBlurPopupDelegate {

    var popupView: UIView {
        containerView ?? UIView()
    }

    var blurEffectStyle: UIBlurEffect.Style? {
        customBlurEffectStyle
    }

    var initialScaleAmmount: CGFloat {
        customInitialScaleAmmount
    }

    var animationDuration: TimeInterval {
        customAnimationDuration
    }

}
