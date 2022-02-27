//
//  ZHOptionBar.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/12.
//

import UIKit

@IBDesignable class ZHOptionBar: UIView {
    
    var penAct: ((_ sender: UIButton)->Void)?
    var lineColorAct: ((_ sender: UIButton)->Void)?
    var lineWidthAct: ((_ sender: UIButton)->Void)?
    
    var textAct: ((_ sender: UIButton)->Void)?
    var circleAct: ((_ sender: UIButton)->Void)?
    var rectAct: ((_ sender: UIButton)->Void)?
    var arrowAct: ((_ sender: UIButton)->Void)?
    
    var singleSelAct: ((_ sender: UIButton)->Void)?
    var multiSelAct: ((_ sender: UIButton)->Void)?
    
    var previousAct: (((_ previousOn: Bool)->Void)->Void)?
    var nextAct: (((_ nextOn: Bool)->Void)->Void)?
    var clearAct: ((_ sender: UIButton)->Void)?
    
    var exitAct: (()->Void)?
    
    @IBOutlet weak var penBtn: UIButton!
    @IBOutlet weak var textBtn: UIButton!
    @IBOutlet weak var circleBtn: UIButton!
    @IBOutlet weak var rectBtn: UIButton!
    @IBOutlet weak var arrowBtn: UIButton!
    
    @IBOutlet weak var singleSelBtn: UIButton!
    @IBOutlet weak var multiSelBtn: UIButton!
    
    @IBOutlet weak var previousBtn: UIButton!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var clearBtn: UIButton!
    
    @IBInspectable var cornerRadius: CGFloat {
        set(value){ layer.cornerRadius = value }
        get{ return layer.cornerRadius }
    }
    
    func reset(){
        penBtn.isSelected = true
        singleSelBtn.isSelected = false
        multiSelBtn.isSelected = false
        singleSelBtn.isEnabled = false
        multiSelBtn.isEnabled = false
        previousBtn.isEnabled = false
        nextBtn.isEnabled = false
        clearBtn.isEnabled = false
    }
    
    @IBAction private func penBtnClick(sender: UIButton){
        resetSelectedBtns()
        sender.isSelected = true
        penAct?(sender)
    }
    @IBAction func colorBtnClick(_ sender: UIButton) {
        let color = UIColor.zh_random()
        sender.backgroundColor = color
        lineColorAct?(sender)
    }
    @IBAction func lineWidthBtnClick(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        lineWidthAct?(sender)
    }
    
    @IBAction func textBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        textAct?(sender)
    }
    @IBAction func circleBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        circleAct?(sender)
    }
    @IBAction func rectBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        rectAct?(sender)
    }
    @IBAction func arrowBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        arrowAct?(sender)
    }
    
    @IBAction func singleSelBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        singleSelAct?(sender)
    }
    @IBAction func multiSelBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        sender.isSelected = true
        multiSelAct?(sender)
    }
    
    @IBAction func previousBtnClick(_ sender: UIButton) {
        nextBtn.isEnabled = true
        previousAct?({ previousOn in
            sender.isEnabled = previousOn
            if !previousOn {
                self.singleSelBtn.isEnabled = false
                self.multiSelBtn.isEnabled = false
            }
        })
    }
    @IBAction func nextBtnClick(_ sender: UIButton) {
        if !previousBtn.isEnabled {
            previousBtn.isEnabled = true
            singleSelBtn.isEnabled = true
            multiSelBtn.isEnabled = true
        }
        nextAct?({ nextOn in
            sender.isEnabled = nextOn
        })
    }
    
    @IBAction func clearBtnClick(_ sender: UIButton) {
        resetSelectedBtns()
        reset()
        clearAct?(sender)
    }
    
    @IBAction func exitBtnClick(_ sender: UIButton) {
        exitAct?()
    }
    
    private func resetSelectedBtns(){
        penBtn.isSelected = false
        textBtn.isSelected = false
        circleBtn.isSelected = false
        rectBtn.isSelected = false
        arrowBtn.isSelected = false
        singleSelBtn.isSelected = false
        multiSelBtn.isSelected = false
    }
}
