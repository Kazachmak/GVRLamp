//
//  AddLampViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 26.11.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit
import Network
import InputMask

class AddLampViewController: UIViewController, MaskedTextFieldDelegateListener  {

    var timer = Timer()
    
    @IBOutlet var listener: MaskedTextFieldDelegate!
    
    @IBOutlet weak var addingLampLabel: UILabel!
    
    @IBOutlet weak var backArrowHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var interval1: NSLayoutConstraint!
    
    @IBOutlet weak var interval2: NSLayoutConstraint!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func cancelButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true)
    }
    
   
    
    
    @IBOutlet weak var ipTextField: UITextField!
    
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var addLampOut: UIButton!
    
    
    private func searchAndAddNewLamp(){
        if let ip = ipTextField.text, var port = portTextField.text{
            if port == ""{
                port = "8888"
            }
            if ip.isValidIP() && port.isValidPort() {
              
                    
                if !lamps.checkIP(ip){
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.addingLampLabel.text = searchingForLamp
                            self.addingLampLabel.isHidden = false
                            })
                    _ = LampDevice(hostIP: NWEndpoint.Host(ip), hostPort: NWEndpoint.Port(port) ?? 8888, name: ip, listOfEffects: LampDevice.listOfEffectsDefault, newLamp: true)
                        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.addingLampLabel.text = lampDidNotFound
                                self.addingLampLabel.isHidden = false
                                })
                        }
                    }else{
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.addingLampLabel.text = lampHasAlreadyBeenAdded
                            self.addingLampLabel.isHidden = false
                            
                            })
                        _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
                            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.addingLampLabel.isHidden = true
                                })
                        }
                    }
                
                
            }else{
                UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.addingLampLabel.text = invalidIPAddress
                    self.addingLampLabel.isHidden = false
                    
                    })
            }
        }
        
    }
    
    @IBAction func addLamp(_ sender: UIButton) {
       searchAndAddNewLamp()
    }
    
    @objc func updateLamp(notification: Notification?) {
        timer.invalidate()
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.addingLampLabel.text = lampWasAdded
            self.addingLampLabel.isHidden = false
            })
        _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.addingLampLabel.isHidden = true
                })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        backArrowHeight.constant += self.view.safeAreaTop - 20
        headerViewHeight.constant += self.view.safeAreaTop - 20
        ipTextField.keyboardType = .decimalPad
        portTextField.keyboardType = .numberPad
        
        ipTextField.setLeftPaddingPoints(20.0)
        portTextField.setLeftPaddingPoints(20.0)
        
        ipTextField.layer.cornerRadius = 14
        portTextField.layer.cornerRadius = 14
        
        addLampOut.imageView?.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("newLampHasAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if UIScreen.main.bounds.height < 569{
            interval1.constant = 20
            interval2.constant = 20
        }
        if UIScreen.main.bounds.height < 670{
            if (self.view.frame.origin.y == 0){
                self.view.frame.origin.y -= 190
            }
        }else{
            if (self.view.frame.origin.y == 0){
                self.view.frame.origin.y -= 280
           }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        interval1.constant = 42
        interval2.constant = 42
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
  
}
