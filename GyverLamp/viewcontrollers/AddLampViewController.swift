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
    
    @IBOutlet weak var lampImage: UIImageView!
    
    var ifNeedMoveView = true
    
    @IBOutlet weak var addingLampLabel: UILabel!
    
    @IBOutlet weak var backArrowHeight: NSLayoutConstraint!
    
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    
    
    @IBAction func close(_ sender: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func returnToMainView(_ sender: UIButton) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var ipTextField: UITextField!
    
    @IBOutlet weak var portTextField: UITextField!
    
    @IBOutlet weak var nameLamp: UITextField!
    
    @IBOutlet weak var addLampOut: UIButton!
    
    
    @IBAction func ipDidBegin(_ sender: UITextField) {
        ifNeedMoveView = false
    }
    
    @IBAction func ipDidEnd(_ sender: UITextField) {
        ifNeedMoveView = true
    }
    
    
    @IBAction func addLamp(_ sender: UIButton) {
        if let ip = ipTextField.text, var port = portTextField.text, var name = nameLamp.text{
            if name == "" {
                name = ip
            }
            if port == ""{
                port = "8888"
            }
            if ip.isValidIP() && port.isValidPort() {
                if let listOfLamps = UserDefaults.standard.array(forKey: "listOfLamps") as? [String]{
                    var arrayIP: [String] = []
                    for element in listOfLamps{
                        arrayIP.append(element.components(separatedBy: ":")[0])
                    }
                    if !arrayIP.contains(ip){
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.addingLampLabel.text = "Идет поиск лампы..."
                            self.addingLampLabel.isHidden = false
                            })
                        _ = LampDevice(hostIP: NWEndpoint.Host(ip), hostPort: NWEndpoint.Port(port) ?? 8888, name: name, effectsFromLamp: "0")
                        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { timer in
                            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.addingLampLabel.text = "Лампа не найдена"
                                self.addingLampLabel.isHidden = false
                                })
                        }
                    }else{
                        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                            self.addingLampLabel.text = "Лампа уже была добавлена"
                            self.addingLampLabel.isHidden = false
                            
                            })
                        _ = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: false) { timer in
                            UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                self.addingLampLabel.isHidden = true
                                })
                        }
                    }
                }else{
                    _ = LampDevice(hostIP: NWEndpoint.Host(ip), hostPort: NWEndpoint.Port(port) ?? 8888, name: name, effectsFromLamp: "0")
                }
                
            }else{
                UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.addingLampLabel.text = "Неверный IP - адрес"
                    self.addingLampLabel.isHidden = false
                    
                    })
            }
        }
    }
    
    @objc func updateLamp(notification: Notification?) {
        timer.invalidate()
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.addingLampLabel.text = "Лампа добавлена"
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
        nameLamp.autocorrectionType = .no
        ipTextField.setLeftPaddingPoints(20.0)
        portTextField.setLeftPaddingPoints(20.0)
        nameLamp.setLeftPaddingPoints(20.0)
        ipTextField.layer.cornerRadius = 14
        portTextField.layer.cornerRadius = 14
        nameLamp.layer.cornerRadius = 14
        addLampOut.imageView?.contentMode = .scaleAspectFit
        NotificationCenter.default.addObserver(self, selector: #selector(updateLamp), name: Notification.Name("newLampHasAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if UIScreen.main.bounds.height < 667 {
            lampImage.isHidden = true
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
          
            if (self.view.frame.origin.y == 0)&&(ifNeedMoveView) {
                self.view.frame.origin.y -= 200
            
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
  
}
