//
//  Empty2ViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 21.05.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import UIKit
import MIBlurPopup

class Empty2ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet var mainView: UIView!
    
    
    var customBlurEffectStyle: UIBlurEffect.Style?
    var customInitialScaleAmmount: CGFloat!
    var customAnimationDuration: TimeInterval!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    

  

}

extension Empty2ViewController: MIBlurPopupDelegate {
    
    
        
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
