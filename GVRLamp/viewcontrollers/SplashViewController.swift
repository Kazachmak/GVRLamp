//
//  SplashViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 08.12.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {
    
    @IBOutlet var nameLabel: UILabel!

   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lamps.loadData()
        var i: Float = 1
        _ = Timer.scheduledTimer(withTimeInterval: 0.015, repeats: true) { timer in
            if i != 52 {
                self.nameLabel.text = "GVR\nLamp"
                self.nameLabel.font = UIFont.boldSystemFont(ofSize: CGFloat(i))
                self.nameLabel.alpha = CGFloat(i / 52)
                i += 1
            } else {
                timer.invalidate()
                sleep(1)
                DispatchQueue.main.async(execute: {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
                    UIApplication.shared.keyWindow?.rootViewController = vc
                })
            }
        }
    }
}
