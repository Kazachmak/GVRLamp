//
//  WebViewViewController.swift
//  GyverLamp
//
//  Created by Максим Казачков on 16.11.2021.
//  Copyright © 2021 Maksim Kazachkov. All rights reserved.
//

import UIKit
import WebKit

class WebViewViewController: UIViewController {

    var lamp: LampDevice?
   
    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet var backArrowHeight: NSLayoutConstraint!

    @IBOutlet var headerViewHeight: NSLayoutConstraint!

    @IBAction func close(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }

    @IBAction func returnToMainView(_ sender: UIButton) {
        view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backArrowHeight.constant += view.safeAreaTop - 20
        headerViewHeight.constant += view.safeAreaTop - 20
        
        if let espMode = lamp?.espMode{
            if espMode{
                let request = URLRequest(url: URL(string: "http://192.168.1.48")!)
                webView.load(request)
            }else{
                let request = URLRequest(url: URL(string: "http://" + "\(String(describing: lamp?.hostIP))")!)
                webView.load(request)
            }
        }
    }
}
