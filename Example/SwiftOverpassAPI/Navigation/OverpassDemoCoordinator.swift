//
//  OverpassDemoNavigationCoordinator.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import SwiftOverpassAPI

class OverpassDemoCoordinator {
	
	let navigationController: UINavigationController
	
	init(navigationController: UINavigationController) {
		self.navigationController = navigationController
	}
	
	func start() {
		showDemoSelect(animated: false)
	}
	
	private func showDemoSelect(animated: Bool) {
		let viewModel = SelectDemoTableViewModel()
		viewModel.delegate = self
		let viewController = TableViewController(viewModel: viewModel)
		viewController.title = "Select a demo"
		navigationController.pushViewController(viewController, animated: animated)
	}
}

extension OverpassDemoCoordinator: SelectDemoTableViewModelDelegate {
	func selecDemoTableViewModel(didSelect demo: Demo) {
		
		let viewModel = DemoViewModel(demo: demo, overpassClient: OverpassClient())
		let viewController = DemoViewController(viewModel: viewModel)
		viewController.title = demo.title
		navigationController.pushViewController(viewController, animated: true)
	}
}
