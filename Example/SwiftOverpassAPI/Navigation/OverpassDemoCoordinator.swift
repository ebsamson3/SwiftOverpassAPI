//
//  OverpassDemoNavigationCoordinator.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import SwiftOverpassAPI

// A basic coordinatator class that controls navigation and view controller instantiation
class OverpassDemoCoordinator {
	
	let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	// Starting the coordinator
	func start() {
		showDemoSelect(animated: false)
	}
	
	// On start show the demo select table view.
	private func showDemoSelect(animated: Bool) {
		let viewModel = SelectDemoTableViewModel()
		viewModel.delegate = self
		let viewController = TableViewController(viewModel: viewModel)
		viewController.title = "Select a demo"
		navigationController.pushViewController(viewController, animated: animated)
	}
}

extension OverpassDemoCoordinator: SelectDemoTableViewModelDelegate {
	// Whenever a demo is selected, navigate to that demo
	func selecDemoTableViewModel(didSelect demo: Demo) {
		let client = OverpassClient()
		let viewModel = DemoViewModel(demo: demo, overpassClient: client)
		let viewController = DemoViewController(viewModel: viewModel)
		viewController.title = demo.title
		navigationController.pushViewController(viewController, animated: true)
	}
}
