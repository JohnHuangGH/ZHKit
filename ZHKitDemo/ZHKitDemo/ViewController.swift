//
//  ViewController.swift
//  ZHKitDemo
//
//  Created by NetInfo on 2022/1/6.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }

    func setupUI(){
        navigationItem.title = "ZHKitDemo"
        
        let navBtnL = UIButton(frame: CGRect(x: 0, y: 0, width: 80, height: 40))
        navBtnL.setTitle("showItem", for: .normal)
        navBtnL.setTitleColor(.orange, for: .normal)
        navBtnL.addTarget(self, action: #selector(navItemActL), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: navBtnL)
        
        let navBtnR = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        navBtnR.setTitle("present", for: .normal)
        navBtnR.setTitleColor(.orange, for: .normal)
        navBtnR.addTarget(self, action: #selector(navItemActR), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navBtnR)
        
        let rotateBtnP = UIButton(frame: .zero)
        rotateBtnP.setTitle("Portrait", for: .normal)
        rotateBtnP.backgroundColor = .darkGray
        rotateBtnP.addTarget(self, action: #selector(rotateBtnPClick), for: .touchUpInside)
        view.addSubview(rotateBtnP)
        rotateBtnP.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(60)
        }
        
        let rotateBtnL = UIButton(frame: .zero)
        rotateBtnL.setTitle("Left", for: .normal)
        rotateBtnL.backgroundColor = .darkGray
        rotateBtnL.addTarget(self, action: #selector(rotateBtnLClick), for: .touchUpInside)
        view.addSubview(rotateBtnL)
        rotateBtnL.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(rotateBtnP)
            make.right.equalTo(rotateBtnP.snp.left).offset(-10)
        }
        
        let rotateBtnR = UIButton(frame: .zero)
        rotateBtnR.setTitle("Right", for: .normal)
        rotateBtnR.backgroundColor = .darkGray
        rotateBtnR.addTarget(self, action: #selector(rotateBtnRClick), for: .touchUpInside)
        view.addSubview(rotateBtnR)
        rotateBtnR.snp.makeConstraints { make in
            make.centerY.width.height.equalTo(rotateBtnP)
            make.left.equalTo(rotateBtnP.snp.right).offset(10)
        }
    }
    
    @objc func navItemActL(){
        let floatingBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        floatingBtn.setTitle("floating", for: .normal)
        floatingBtn.backgroundColor = .blue
        floatingBtn.layer.cornerRadius = 30
        floatingBtn.layer.masksToBounds = true
        floatingBtn.addTarget(self, action: #selector(floatingBtnClick), for: .touchUpInside)
        JHFloatingItem.show(item: floatingBtn, rootVC: self)
    }
    
    @objc func navItemActR(){
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.view.backgroundColor = .darkGray
        vc.view.zh_tapGestureAdd(target: self, action: #selector(presentVcTap))
        present(vc, animated: true, completion: nil)
    }
    
    @objc func presentVcTap(){
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func floatingBtnClick(){
        print("floatingBtnClick")
        JHFloatingItem.close()
    }
    
    @objc func rotateBtnPClick(){
        print("rotateBtnPClick:\(UIDeviceOrientation.portrait.rawValue)")
        UIDevice.change(deviceOrientation: .portrait)
    }
    
    @objc func rotateBtnLClick(){
        print("rotateBtnLClick:\(UIDeviceOrientation.landscapeLeft.rawValue)")
        UIDevice.change(deviceOrientation: .landscapeLeft)
    }
    
    @objc func rotateBtnRClick(){
        print("rotateBtnRClick:\(UIDeviceOrientation.landscapeRight.rawValue)")
        UIDevice.change(deviceOrientation: .landscapeRight)
    }
}

