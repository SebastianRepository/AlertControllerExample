//
//  AlertController.swift
//  sms
//
//  Created by Sebastian on 28.05.15.
//  Copyright (c) 2015 Sebastian Frederik Sattler. All rights reserved.
//

import UIKit

/*The button combinations supported by AlertController*/
public enum AlertControllerButtons: Int {
	
	/*If two button titles are given in one case, the first one will be on the left and the second on the right
	According to Apple's human interface design guidelines, the placing should be chosen according to this:
	“When the most likely button performs a nondestructive action, it should be on the right in a two-button alert. The button that cancels this action should be on the left.
	When the most likely button performs a destructive action, it should be on the left in a two-button alert. The button that cancels this action should be on the right.”
	
	Remark: the style 'Cancel' means bold letters, i.e. 'safe choice'. So .Cancel may also be used with "Continue" if that is the safest choice for the user.
	*/
    case OK = 0
    case CancelOK = 1
    case CancelContinue = 2
	case OptionsContinue = 3
	case SkipOptions = 4
	case SkipContinue = 5
	case InterruptContinue = 6
	case NoYes = 7
}

/*
Conveniently presents a UIAlertController.
Action handlers can be handed over through closures. There is one closure each for button 1 and 2.
The button combinations are defined in AlertControllerButtons.
If only one button is present on the user alert, the closure 'btn2Action' will be disregarded. 
*/

public class AlertController {
   
    public func present(parent parent: UIViewController, title: String, messageText: String, buttons: AlertControllerButtons, btn1Action: (() -> Void)?, btn2Action: (() -> Void)?) {
		
		let alertActionOK1 = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) -> Void in
            if let action = btn1Action {
                action()}
        }  //OK = Button1
        let alertActionOK2 = UIAlertAction(title: "OK", style: .Default) { (UIAlertAction) -> Void in
            if let action = btn2Action {
                action()}
        }  //OK = Button2
        let alertActionContinue = UIAlertAction(title: "Continue", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            if let action = btn2Action {
                action()}
        } //Continue  = Button2
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .Cancel) { (UIAlertAction) -> Void in
            if let action = btn1Action {
                action()}
		} //Cancel  = Button1
		let alertActionOptions1 = UIAlertAction(title: "Options", style: .Default) { (UIAlertAction) -> Void in
			if let action = btn1Action {
				action()}
		} //Check-in-Options = Button 1
		let alertActionOptions2 = UIAlertAction(title: "Options", style: .Default) { (UIAlertAction) -> Void in
			if let action = btn2Action {
				action()}
		} //Check-in-Options = Button 2
		let alertActionSkip = UIAlertAction(title: "Skip", style: .Destructive) { (UIAlertAction) -> Void in
			if let action = btn1Action {
				action()}
		} //Skip = Button 1
        let alertActionInterrupt = UIAlertAction(title: "Interrupt", style: .Default) { (UIAlertAction) -> Void in
			if let action = btn1Action {
				action()}
		} //Interrupt = Button 1
		let alertActionYes = UIAlertAction(title: "Yes", style: .Default) { (UIAlertAction) -> Void in
			if let action = btn2Action {
				action()
			}
		} //Yes = Button 2
		let alertActionNo = UIAlertAction(title: "No", style: .Cancel) { (UIAlertAction) -> Void in
			if let action = btn1Action {
				action()
			}
		} //No = Button 1
		
        if objc_getClass("UIAlertController") != nil {

            let alert = UIAlertController(title: title, message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
            
            switch buttons {
							
            case .CancelOK:
                alert.addAction(alertActionOK2)
                alert.addAction(alertActionCancel)
            
            case .CancelContinue:
                alert.addAction(alertActionContinue)
                alert.addAction(alertActionCancel)
			
			case .OptionsContinue:
				alert.addAction(alertActionContinue)
				alert.addAction(alertActionOptions1)
				
			case .SkipOptions:
				alert.addAction(alertActionOptions2)
				alert.addAction(alertActionSkip)
				
			case .SkipContinue:
				alert.addAction(alertActionContinue)
				alert.addAction(alertActionSkip)
				
			case .InterruptContinue:
				alert.addAction(alertActionContinue)
				alert.addAction(alertActionInterrupt)
				
			case .NoYes:
				alert.addAction(alertActionYes)
				alert.addAction(alertActionNo)
			
            case .OK: fallthrough
				
            default:
                alert.addAction(alertActionOK1)
            }
            parent.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
			parent.presentViewController(alert, animated: true) { () -> Void in }
            
        } else {
            
            //%ERROR HANDLING Wrong OS %
        }
    }
}