//
//  UIViewController+Extensions.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

// Functions for adding and removing child view controllers from a parent view controller
extension UIViewController {
	
	private func add(childViewController viewController: UIViewController) {
		addChild(viewController)
		viewController.didMove(toParent: self)
	}
	
	private func remove(asChildViewController viewController: UIViewController) {
		viewController.willMove(toParent: nil)
		viewController.view.removeFromSuperview()
		viewController.removeFromParent()
	}
}
