//
//  SettingsViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import Network
import UIKit

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // обновлять таблицу или нет
    var updateTableFlag = true

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }

    @IBOutlet var heightOfErrorLabel: NSLayoutConstraint!

    @IBOutlet var tableView: UITableView!

    private func setMainLamp(_ index: Int) {
        lamps.setMainLamp(index)
    }

    // свайп ячеек
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?{
        updateTableFlag = false
        // добавляем лампу в список управляемых
        
        if  lamps.arrayOfLamps[indexPath.row].flagLampIsControlled {
            let AddAction = UIContextualAction(style: .destructive, title: removeFromGroup, handler: { [self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                lamps.arrayOfLamps[indexPath.row].flagLampIsControlled = false
                
                success(true)
                updateTableFlag = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    updateTable()
                }
               
            })
            AddAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [AddAction])
        } else {
            let AddAction = UIContextualAction(style: .destructive, title: addToGroup, handler: { [self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                let newAddedLamp = lamps.arrayOfLamps[indexPath.row]
                newAddedLamp.flagLampIsControlled = true
                success(true)
                updateTableFlag = true
                newAddedLamp.lampBlink()
                lamps.alignLampParametersAfterNewLampAdded(newAddedLamp)
                
                // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //    updateTable()
                //}
            })
            AddAction.backgroundColor = .gray
            
            return UISwipeActionsConfiguration(actions: [AddAction])
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lamps.setMainLamp(indexPath.row)

        _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [self] _ in

            if lamps.mainLamp?.connectionStatus == true {
                self.dismiss(animated: true)
            } else {
                UIView.transition(with: self.view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.heightOfErrorLabel.constant = 24
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lamps.arrayOfLamps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "lampCell", for: indexPath) as! LampsTableViewCell

       
        cell.lampLabel.text = lamps.arrayOfLamps[indexPath.row].name
        
        
        if lamps.arrayOfLamps.count > 0 {
            if cell.lampLabel.text == "\(lamps.mainLamp?.name ?? "")" {
                cell.lampLabel.textColor = redColor // текущая лампа подсвечена красным
                cell.settingsButtonOut.alpha = 1.0
        }else{
            if lamps.arrayOfLamps[indexPath.row].flagLampIsControlled {
                cell.lampLabel.textColor = violetColor // управляемая лампа подсвечена фиолетовым
            }else{
                cell.lampLabel.textColor = blackColor
            }
            cell.settingsButtonOut.alpha = 0.3
            }
        }
        return cell
    }

    @IBAction func settingsButton(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = tableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }

        lamps.arrayOfLamps[indexPath.row].lampBlink()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lampsettings") as! LampSettingsViewController
        vc.lamp = lamps.arrayOfLamps[indexPath.row]
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

    @IBAction func add41(_ sender: UIButton) {
        LampDevice.scan(deviceIp: "192.168.4.1")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !lamps.checkIP("192.168.4.1"){
                        // create the alert
                        let alert = UIAlertController(title: lampNotFound, message: youNotConnectedToLedLamp, preferredStyle: UIAlertController.Style.alert)

                        // add the actions (buttons)
                        alert.addAction(UIAlertAction(title: openSettings, style: UIAlertAction.Style.default, handler: {action in UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil) }))
                        
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))

                        // show the alert
                        self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBOutlet weak var add41ButtobOut: UIButton!
    
    
    @IBOutlet var addButtonOut: UIButton!

    // обновляем таблицу
    @objc func updateTable() {
        if updateTableFlag {
            tableView.reloadData()
        }
    }

    @IBOutlet var scanOut: UIButton!

    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    override func viewWillAppear(_ animated: Bool) {
        // читаем из памяти список сохранненых ламп
        updateTable()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        heightOfErrorLabel.constant = 0
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        NotificationCenter.default.addObserver(self, selector: #selector(updateTable), name: Notification.Name("updateInterface"), object: nil)
        tableView.separatorStyle = .none
        scanOut.imageView?.contentMode = .scaleAspectFit
        addButtonOut.imageView?.contentMode = .scaleAspectFit
        add41ButtobOut.imageView?.contentMode = .scaleAspectFit
        
    }
}
