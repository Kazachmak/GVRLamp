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

        if indexPath.row != lamps.mainLampIndex {
        
        if  lamps.arrayOfLamps[indexPath.row].flagLampIsControlled {
            let AddAction = UIContextualAction(style: .destructive, title: "Убрать из управляемые", handler: { [self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                lamps.arrayOfLamps[indexPath.row].flagLampIsControlled = false
                success(true)
                updateTableFlag = true
                
            })
            AddAction.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [AddAction])
        } else {
            let AddAction = UIContextualAction(style: .destructive, title: "Добавить в управляемые", handler: { [self] (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
                lamps.arrayOfLamps[indexPath.row].flagLampIsControlled = true
                success(true)
                updateTableFlag = true
                
            })
            AddAction.backgroundColor = .gray
        
            return UISwipeActionsConfiguration(actions: [AddAction])
        }
        
        }else{
            return nil
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

        lamps.setMainLamp(indexPath.row)

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "lampsettings") as! LampSettingsViewController
        vc.lamp = lamps.mainLamp
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }

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
    }
}
