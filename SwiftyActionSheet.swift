//
//  SwiftyActionSheet.swift
//
//  Created by Jing Zhou on 2016-04-24.
//  Copyright © 2016 Jing Zhou. All rights reserved.
//

import UIKit

public class SwiftyActionSheet: UIViewController, UIGestureRecognizerDelegate {
    
    private var configuration = Configurations()
    private var menuView = UIView()
    private var actionButtons = [ActionButton]()
    
    class ActionButton: UIButton {
        var action: (() -> Void)!
        
        // http://stackoverflow.com/a/29186375/1062364
        override var highlighted: Bool {
            didSet {
                backgroundColor = highlighted ? UIColor.lightGrayColor() : UIColor.whiteColor()
            }
        }
    }
    
    public var buttonHeight: CGFloat {
        get {
            return self.configuration.buttonHeight
        }
        set(value) {
            self.configuration.buttonHeight = value
        }
    }
    
    public var overlayColor: UIColor {
        get {
            return self.configuration.overlayColor
        }
        set(value) {
            self.configuration.overlayColor = value
        }
    }
    
    public var buttonGap: CGFloat {
        get {
            return self.configuration.buttonGap
        }
        set(value) {
            self.configuration.buttonGap = value
        }
    }
    
    public var separatorColor: UIColor {
        get {
            return self.configuration.separatorColor
        }
        set(value) {
            self.configuration.separatorColor = value
        }
    }
    
    public var cancelButtonText: String {
        get {
            return self.configuration.cancelButtonText
        }
        set(value) {
            self.configuration.cancelButtonText = value
        }
    }
    
    public var cancelButtonTextColor: UIColor {
        get {
            return self.configuration.cancelButtonTextColor
        }
        set(value) {
            self.configuration.cancelButtonTextColor = value
        }
    }
    
    public var animationDuration: NSTimeInterval {
        get {
            return self.configuration.animationDuration
        }
        set(value) {
            self.configuration.animationDuration = value
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        view.frame = UIScreen.mainScreen().bounds
        view.autoresizingMask = [UIViewAutoresizing.FlexibleHeight, UIViewAutoresizing.FlexibleWidth]
        view.backgroundColor = UIColor.clearColor()
        
        menuView.frame = view.frame
        view.addSubview(menuView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SwiftyActionSheet.dismiss))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }
    
    public func dismiss() {
        UIView.animateWithDuration(animationDuration, animations: {
            self.view.alpha = 0
            var frame = self.menuView.frame
            frame.origin.y += frame.size.height
            self.menuView.frame = frame
            }, completion: { _ in
                self.view.removeFromSuperview()
        })
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view != gestureRecognizer.view {
            return false
        }
        return true
    }
    
    public func addbutton(title: String, isCancelButton: Bool=false, action: () -> Void) {
        let btn = ActionButton()
        btn.layer.masksToBounds = true
        btn.action = action
        // cancel button has a different text color. customizable.
        if isCancelButton {
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(cancelButtonTextColor, forState: .Normal)
        } else {
            btn.setTitle(title, forState: .Normal)
            btn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        }
        btn.addTarget(self, action: #selector(SwiftyActionSheet.buttonTapped(_:)), forControlEvents: .TouchUpInside)
        menuView.addSubview(btn)
        actionButtons.append(btn)
    }
    
    func addCancelButton(title: String) {
        self.addbutton(title, isCancelButton: true) {
            self.dismiss()
        }
    }
    
    func buttonTapped(btn: ActionButton) {
        btn.action()
        dismiss()
    }
    
    public func show() {
        guard let rv = UIApplication.sharedApplication().keyWindow else {
            return
        }
        rv.addSubview(view)
        
        menuView.backgroundColor = UIColor.clearColor()
        
        self.addCancelButton(cancelButtonText)
        
        let menuHeight = CGFloat(actionButtons.count - 1)*buttonGap + CGFloat(actionButtons.count)*buttonHeight
        menuView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: menuHeight)
        // add buttons and separators to menuView
        for (index, btn) in actionButtons.enumerate() {
            btn.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: buttonHeight)
            btn.center = CGPoint(x: view.center.x, y: buttonHeight*CGFloat(index+1) + CGFloat(index)*buttonGap-0.5*buttonHeight)
            btn.backgroundColor = UIColor.whiteColor()
            // add separators
            if index > 0 {
                let line = UIView()
                menuView.addSubview(line)
                line.frame = CGRect(x: 0.0, y: buttonHeight*CGFloat(index) + CGFloat(index-1)*buttonGap, width: view.frame.width, height: buttonGap)
                line.backgroundColor = separatorColor
            }
        }
        
        UIView.animateWithDuration(animationDuration, animations: {
            self.view.backgroundColor = self.overlayColor
            self.menuView.frame = CGRect(x: 0, y: self.view.frame.height-menuHeight, width: self.view.frame.width, height: menuHeight)
            
        })
    }
}

class Configurations {
    var buttonHeight: CGFloat
    var cancelButtonText: String
    var cancelButtonTextColor: UIColor
    var overlayColor: UIColor
    var buttonGap: CGFloat
    var separatorColor: UIColor
    var animationDuration: NSTimeInterval
    
    init() {
        self.buttonHeight = 55
        self.cancelButtonText = "Cancel"
        self.cancelButtonTextColor = UIColor(red: 255.0/255.0, green: 10.0/255.0, blue: 10.0/255.0, alpha: 1.0)
        self.overlayColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.6)
        self.buttonGap = 1
        self.separatorColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0)
        self.animationDuration = 0.4
    }
}