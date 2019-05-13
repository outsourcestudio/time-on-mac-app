//
//  ButtonSwitcher.swift
//  UserActivity
//
//  Created by RoboApps on 3/19/19.
//  Copyright © 2019 RoboApps. All rights reserved.
//

import Cocoa

class ButtonSwitcher: NSView {
    
    private var buttonLayers = [CALayer]()
    private var textLayers = [CATextLayer]()
    private var titles = [String]()
    private var bgColor: NSColor!
    private var selectedColor:NSColor!
    private var parentFrame:NSRect!
    
    private var switchValueChanged:((Int) -> Void)?
    
    public init(frame:NSRect, titles: [String], bgColor: NSColor, selectedColor: NSColor) {
        super.init(frame: frame)
        
        guard titles.count > 0 else { return }
        self.titles = titles
        self.bgColor = bgColor
        self.selectedColor = selectedColor
        self.parentFrame = frame
        self.wantsLayer = true
        self.layer?.backgroundColor = bgColor.cgColor
        self.layer?.cornerRadius = 14.0
        self.layer?.masksToBounds = true
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        clearButtons()
        let buttonSize = NSSize(width: parentFrame.width / CGFloat(titles.count), height: parentFrame.height)
        var x:CGFloat = 0
        titles.forEach { (title) in
            let layer: CALayer = CALayer()
            layer.frame = NSRect(x: x, y: 0, width: buttonSize.width, height: buttonSize.height)
            layer.cornerRadius = 14.0
            layer.masksToBounds = true
            layer.backgroundColor =  bgColor.cgColor
            layer.masksToBounds = true
            x += buttonSize.width
            
            let textSize = NSSize(width: buttonSize.width, height: 16)
            let y = buttonSize.height / 2.0 - textSize.height / 2.0
            let textLayer: CATextLayer = CATextLayer()
            textLayer.string = title
            textLayer.frame = NSRect(x: 0, y: y, width: textSize.width, height: textSize.height)
            textLayer.font = CGFont("SFProDisplay-Medium" as CFString)!
            textLayer.fontSize = 12.0
            textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 1.0
            
            textLayer.alignmentMode = .center
            textLayer.foregroundColor = NSColor.black.cgColor
            textLayer.backgroundColor = NSColor.clear.cgColor
    
            layer.addSublayer(textLayer)
            textLayers.append(textLayer)
            self.layer?.addSublayer(layer)
            buttonLayers.append(layer)
        }
    }
    
    private func clearButtons(){
        guard buttonLayers.count > 0 && textLayers.count > 0 else { return }
        for i in 0..<titles.count {
            buttonLayers[i].removeFromSuperlayer()
            textLayers[i].removeFromSuperlayer()
        }
        buttonLayers.removeAll()
        textLayers.removeAll()
    }
    
    func didClick(callback:@escaping (Int) -> Void) {
        switchValueChanged = callback
    }
    
    func selectButton(index:Int){
        for i in 0..<titles.count {
            let button:CALayer = buttonLayers[i]
            let textLayer:CATextLayer = textLayers[i]
            button.backgroundColor = bgColor.cgColor
            textLayer.foregroundColor = NSColor.black.cgColor
            if i ==  index{
                button.backgroundColor = selectedColor.cgColor
                textLayer.foregroundColor = NSColor.white.cgColor
            }
        }
    }
    
    override func mouseDown(with theEvent: NSEvent) {
        let p = (self.window?.contentView?.convert(theEvent.locationInWindow, to: self))!
        let layers = self.layer?.sublayers ?? []
        for (i, layer) in layers.enumerated() {
            layer.borderWidth = 0
            if layer.frame.contains(p) {
                self.selectButton(index: i)
                self.switchValueChanged?(i)
                break
            }
        }

    }

    
}
