//
//  NSLayoutContstraint+Extensions.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	func withPriority(_ priority: UILayoutPriority ) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}
	
	func withActivitionState(_ isActive: Bool) -> NSLayoutConstraint {
		self.isActive = isActive
		return self
	}
}
