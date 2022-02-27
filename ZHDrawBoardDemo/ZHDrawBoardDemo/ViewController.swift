//
//  ViewController.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

class ViewController: UIViewController {
    
    var img: UIImage = UIImage.zh_pureColorImage(color: .white, size: UIScreen.main.bounds.size)
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .darkContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let bgImg = UIImage(named: "bgimg") else { return }
        img = bgImg
    }
    
    @IBAction func screenShotBtnClick(_ sender: UIButton) {
        guard let shotImg = UIImage.zh_screenShot() else { return }
        img = shotImg
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ZHDrawBoardVC
        vc?.modalPresentationStyle = .fullScreen
        vc?.bgImage = img
    }
}

