//
//  SelectableCellViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/15/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

class SelectableCellViewModel {
	
	private static let reuseIdentifier = "SelectableCellViewModel"
	
	let title: String
	var selectionHandler: (() -> Void)?
	
	init(title: String) {
		self.title = title
	}
}

extension SelectableCellViewModel: CellRepresentable {
	static func registerCell(tableView: UITableView) {
		
		tableView.register(
			UITableViewCell.self,
			forCellReuseIdentifier: reuseIdentifier)
	}
	
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(
			withIdentifier: SelectableCellViewModel.reuseIdentifier,
			for: indexPath)
		
		cell.textLabel?.text = title
		return cell
	}
}

extension SelectableCellViewModel: CellSelectable {
	func handleCellSelection() {
		selectionHandler?()
	}
}

