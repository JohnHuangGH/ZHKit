//
//  ZHTextPath.swift
//  ZHDrawBoardDemo
//
//  Created by NetInfo on 2022/1/24.
//

import UIKit

class ZHTextPath: ZHBasePath {
    
    var text: String = ""
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init() {
        super.init()
        self.isFill = true
    }
    
    override func draw(to point: CGPoint) {
        let font = lineWidth == 4 ? UIFont.systemFont(ofSize: 20) : UIFont.boldSystemFont(ofSize: 22)
        let attributes = [NSAttributedString.Key.font: font]
        let attrStrM = NSMutableAttributedString(string: text, attributes: attributes)
        let pathM = CGMutablePath()
        let line = CTLineCreateWithAttributedString(attrStrM)
        let glyphRuns = CTLineGetGlyphRuns(line)
        
        for i in 0..<CFArrayGetCount(glyphRuns) {
            let run = unsafeBitCast(CFArrayGetValueAtIndex(glyphRuns, i), to: CTRun.self)
            let key = unsafeBitCast(kCTFontAttributeName, to: UnsafePointer<Any>.self)
            let runFont = unsafeBitCast(CFDictionaryGetValue(CTRunGetAttributes(run), key), to: CTFont.self)
            
            for j in 0..<CTRunGetGlyphCount(run) {
                let glyphRange = CFRangeMake(j, 1)
                var glyph: CGGlyph = 0
                var position: CGPoint = .zero
                CTRunGetGlyphs(run, glyphRange, &glyph)
                CTRunGetPositions(run, glyphRange, &position)
                
                if let path = CTFontCreatePathForGlyph(runFont, glyph, nil) {
                    let transform = CGAffineTransform(translationX: point.x + position.x, y: point.y + position.y).scaledBy(x: 1, y: -1)
                    pathM.addPath(path, transform: transform)
                }
            }
        }
        append(UIBezierPath(cgPath: pathM))
        markPoints.append(point)
    }
    
    override func copyPath() -> Self {
        guard let path = super.copyPath() as? Self else { return self }
        path.text = text
        return path
    }
}
