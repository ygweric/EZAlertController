//
//  EZAlertView.swift
//  EZAlertView
//
//  Created by Furkan Yilmaz on 11/11/15.
//  Copyright © 2015 Furkan Yilmaz. All rights reserved.
//

import UIKit

open class EZAlertController {
    
    //==========================================================================================================
    // MARK: - Singleton
    //==========================================================================================================
    
    class var instance : EZAlertController {
        struct Static {
            static let inst : EZAlertController = EZAlertController ()
        }
        return Static.inst
    }
    
    //==========================================================================================================
    // MARK: - Private Functions
    //==========================================================================================================
    
    fileprivate func topMostController() -> UIViewController? {
        
        var presentedVC = UIApplication.shared.keyWindow?.rootViewController
        while let pVC = presentedVC?.presentedViewController
        {
            presentedVC = pVC
        }
        
        if presentedVC == nil {
            print("EZAlertController Error: You don't have any views set. You may be calling in viewdidload. Try viewdidappear.")
        }
        return presentedVC
    }
    
    
    //==========================================================================================================
    // MARK: - Class Functions
    //==========================================================================================================
    
    open class func alert(_ title: String) -> UIAlertController {
        return alert(title, message: "")
    }
    
    open class func alert(_ title: String, message: String) -> UIAlertController {
        return alert(title, message: message, acceptMessage: "OK") { () -> () in
            // Do nothing
        }
    }
    
    open class func alert(_ title: String, message: String, acceptMessage: String, acceptBlock: @escaping () -> ()) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let acceptButton = UIAlertAction.action(title: acceptMessage, style: .default, handler: { (action: UIAlertAction) in
            acceptBlock()
        })
        alert.addAction(acceptButton)
        
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        return alert
    }
    
    open class func alert(_ title: String, message: String, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController{
        let alert = UIAlertController.alert(title: title, message: message, preferredStyle: .alert, buttons: buttons, tapBlock: tapBlock)
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        return alert
    }
    
    open class func actionSheet(_ title: String?, message: String, sourceView: UIView, actions: [UIAlertAction]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.actionSheet)
        for action in actions {
            alert.addAction(action)
        }
        alert.popoverPresentationController?.sourceView = sourceView
        alert.popoverPresentationController?.sourceRect = sourceView.bounds
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        return alert
    }
    
    open class func actionSheet(_ title: String?, message: String, sender: AnyObject, buttons:[String], cancel: String? = nil, tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController{
        let alert = UIAlertController.alert(title: title, message: message, preferredStyle: .actionSheet, buttons: buttons, tapBlock: tapBlock)
        if cancel != nil {
            let cancelActionButton: UIAlertAction = UIAlertAction.action(title: cancel, style: .cancel) { action -> Void in
                
                if let block = tapBlock {
                    block(action,-1)
                }
            }
            alert.addAction(cancelActionButton)
        }
        if sender.isKind(of: UIView.self) {
            alert.popoverPresentationController?.sourceView = sender as! UIView
            alert.popoverPresentationController?.sourceRect = sender.bounds
        } else if sender.isKind(of: UIBarButtonItem.self) {
            alert.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        }
        instance.topMostController()?.present(alert, animated: true, completion: nil)
        alert.view.layoutIfNeeded()
        return alert
    }
    
}


private extension UIAlertController {
    class func alert(title: String?, message: String?, preferredStyle: UIAlertControllerStyle, buttons:[String], tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle:preferredStyle)
        var buttonIndex = 0
        for buttonTitle in buttons {
            let action = UIAlertAction.action(title: buttonTitle, preferredStyle: .default, buttonIndex: buttonIndex, tapBlock: tapBlock)
            buttonIndex += 1
            alert.addAction(action)
        }
        return alert
    }
}

let actionAccessibility = "accessibility_label_%@"

private extension UIAlertAction {
    
    class func action(title: String?, style: UIAlertActionStyle, handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.accessibilityLabel = String(format: actionAccessibility, title!)
        
        return action
    }
    
    class func action(title: String?, preferredStyle: UIAlertActionStyle, buttonIndex:Int, tapBlock:((UIAlertAction,Int) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction.action(title: title, style: preferredStyle) {
            (action:UIAlertAction) in
            if let block = tapBlock {
                block(action,buttonIndex)
            }
        }
        
        return action
    }
}
