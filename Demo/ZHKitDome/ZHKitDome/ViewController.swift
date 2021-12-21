//
//  ViewController.swift
//  ZHKitDome
//
//  Created by 星网 on 2021/11/15.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let date = Date()
        print(date.zh_12hStr() + date.zh_AmPmStr())
        print(date.zh_12hhStr() + date.zh_AmPmCNStr())
    }


}

