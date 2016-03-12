//
//  ViewController.swift
//  AlertControllerExample
//
//  Created by Sebastiano on 10.03.16.
//  Copyright © 2016 Lancaster. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var touchField: UIView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
	//	initTapAction()
	}
	
	@IBAction func touchFieldAction(sender: AnyObject) {
	
		let actionSheet = ActionSheet()
			
		actionSheet.present(parent: self, title: "Tap to get a message", msg: "Tap here", sourceView: self.touchField, button: ActionSheetButton.MsgText) { () -> Void in
			
			self.presentAlert()
		}
	}
	
	private func presentAlert() {
	
		let alert = AlertController()
		
		alert.present(parent: self, title: "This is a user alert", messageText: "Yes or no?", buttons: AlertControllerButtons.NoYes, btn1Action: { () -> Void in
		
				print("No")
				
			}) { () -> Void in
			
				print("Yes")
		}
	}
}

