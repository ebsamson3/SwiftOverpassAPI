//
//  NSLayoutContstraint+Extensions.swift
//  SwiftOverpassAPI_Example
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

	// Setting constraint priority using dot notation
	func withPriority(_ priority: UILayoutPriority ) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}
	
	// Setting constraint activity using dot notation
	func withActivitionState(_ isActive: Bool) -> NSLayoutConstraint {
		self.isActive = isActive
		return self
	}
}
