//
//  ViewController.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

class ViewController: UIViewController {
    
    var img: UIImage? = UIImage(named: "bgimg")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func screenShotBtnClick(_ sender: UIButton) {
        img = UIImage.zh_ScreenShot()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ZHDrawBoardVC
        vc?.bgImage = img
    }
}

