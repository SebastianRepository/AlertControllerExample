//
//  ActionSheet.swift
//  sms
//
//  Created by Sebastian on 19.08.15.
//  Copyright (c) 2015 Sebastian Frederik Sattler. All rights reserved.
//

import UIKit


public enum ActionSheetButton: Int {

	case None = 0
	case CheckOut = 1  //Destructive (red) check-out button; title & text are displayed
	case MsgText = 2  //Title displayed; msg-text displayed in button title
}

/*
Conveniently presents a UIActionSheet object
*/

public class ActionSheet {
   
    public func present(parent parent: UIViewController, title: String, msg: String, sourceView: UIView, button: ActionSheetButton, btnAction: (() -> Void)?) {
		
        let sheetActionCheckOut = UIAlertAction(title: "Auschecken", style: .Destructive) { (UIAlertAction) -> Void in
			if let action = btnAction {
                action()
			}
        }
		
        let sheetActionMsgText = UIAlertAction(title: msg, style: .Default) { (UIAlertAction) -> Void in
            if let action = btnAction {
                action()
			}
		}
		
        if objc_getClass("UIAlertController") != nil { //Check if the OS supports UIAlertController (from iOS 8.0)
			
			var displayed_msg: String
			
			if button == .MsgText {
				displayed_msg = ""
			} else {
				displayed_msg = msg
			}
			
            let sheet = UIAlertController(title: title, message: displayed_msg, preferredStyle: .ActionSheet)
			
			switch button {
                
            case .CheckOut:
                sheet.addAction(sheetActionCheckOut)
            
            case .MsgText:
                sheet.addAction(sheetActionMsgText)
				
			case .None: fallthrough
			
            default:
				print ("Action sheet without button") 
            }
			
			//Determine the approximate middle of sourceView:
			let rect = CGRect(x: 0, y: 0, width: sourceView.bounds.width, height: sourceView.bounds.height)
			
			sheet.popoverPresentationController?.sourceView = sourceView
			sheet.popoverPresentationController?.sourceRect = rect
            parent.modalPresentationStyle = UIModalPresentationStyle.Popover
			parent.presentViewController(sheet, animated: true) { () -> Void in }
            
        } else {
            
			print("Error: Your OS does not support UIAlertController. Minimum iOS 8.0 is required")
        }
    }
}