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
        
        setDefaultImg()
    }
    
    func setDefaultImg(){
        guard let bgImg = UIImage(named: "bgimgH") else { return }
        img = bgImg
    }
    func setScreenShot(){
        guard let shotImg = UIImage.zh_screenShot() else { return }
        img = shotImg
    }
    
    @IBAction func imgBtnClick(_ sender: UIButton) {
        if sender.titleLabel?.text == "ScreenShot" {
            setScreenShot()
            sender.setTitle("DefaultImg", for: .normal)
        }else{
            setDefaultImg()
            sender.setTitle("ScreenShot", for: .normal)
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? ZHDrawBoardVC
        vc?.modalPresentationStyle = .fullScreen
        vc?.bgImage = img
    }
}

