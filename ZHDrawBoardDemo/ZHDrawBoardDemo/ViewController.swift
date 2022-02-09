//
//  ViewController.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var drawBoard: ZHDrawBoard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawBoard.image = UIImage(named: "bgimg")
    }
}

