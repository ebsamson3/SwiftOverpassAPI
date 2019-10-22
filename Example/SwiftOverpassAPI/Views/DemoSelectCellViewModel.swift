//
//  DemoSelectCellViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

class DemoSelectCellViewModel {
	
	private static let reuseIdentifier = "DemoSelectCell"
	
	let demo: Demo
	var selectionHandler: (() -> Void)?
	
	init(demo: Demo) {
		self.demo = demo
	}
}

extension DemoSelectCellViewModel: CellRepresentable {
	static func registerCell(tableView: UITableView) {
		
		tableView.register(UITableViewCell.self,forCellReuseIdentifier: reuseIdentifier)
	}
	
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: DemoSelectCellViewModel.reuseIdentifier, for: indexPath)
		cell.textLabel?.text = demo.title
		return cell
	}
}

extension DemoSelectCellViewModel: CellSelectable {
	func handleCellSelection() {
		selectionHandler?()
	}
}
