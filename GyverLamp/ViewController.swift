//
//  ViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 18.08.2020.
//  Copyright © 2020 Maksim Kazachkov. All rights reserved.
//

import UIKit

import Network

class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
   
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listOfEffects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "effectCell", for: indexPath) as! EffectCollectionViewCell
        cell.nameOfEffect.text = listOfEffects[indexPath.row]
        cell.addBoxShadow()
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
       {
        
        if UIScreen.main.bounds.height == 568 {
            
            return CGSize(width: 50, height: 50)
            }else{
            
            return CGSize(width: UIScreen.main.bounds.height/5+20, height: UIScreen.main.bounds.height/5+20)
            }
        }
       
    
    
    @IBAction func settingsButton(_ sender: UIButton) {
        
    }

    @IBOutlet var statusLabel: UILabel!

    @IBOutlet var settingsButtonOut: UIButton!

    @IBOutlet var collectionOfEffects: UICollectionView!

    @IBOutlet var brightnessSlider: UISlider!

    @IBOutlet var speedSlider: UISlider!

    @IBOutlet var scaleSlider: UISlider!

    @IBAction func autoswitchingButton(_ sender: UIButton) {
    }

    @IBOutlet var autoswitchingButtonOut: UIButton!

    @IBAction func alarmClock(_ sender: UIButton) {
    }

    @IBOutlet var alarmClockOut: UIButton!

    @IBAction func timer(_ sender: UIButton) {
    }

    @IBOutlet var timerOut: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        alarmClockOut.addBoxShadow()
        timerOut.addBoxShadow()
        autoswitchingButtonOut.addBoxShadow()
        
    
       
       
       
    }
    
    
    
}
