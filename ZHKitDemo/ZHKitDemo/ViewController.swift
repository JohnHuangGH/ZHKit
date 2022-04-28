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
        
        let navBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 40))
        navBtn.setTitle("present", for: .normal)
        navBtn.setTitleColor(.orange, for: .normal)
        navBtn.addTarget(self, action: #selector(navItemRAct), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: navBtn)
        
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 60))
        btn.setTitle("btn", for: .normal)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 30
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(btnAct), for: .touchUpInside)
        JHFloatingHelper.shared.show(contentV: btn)
    }
    
    @objc func navItemRAct(){
        let vc = UIViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.view.backgroundColor = .darkGray
        vc.view.zh_tapGestureAdd(target: self, action: #selector(presentVcTap))
        present(vc, animated: true, completion: nil)
    }
    
    @objc func presentVcTap(){
        presentedViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnAct(){
        print("btnClick")
    }
}

