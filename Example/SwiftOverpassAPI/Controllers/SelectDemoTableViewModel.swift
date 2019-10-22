//
// SelectDemoTableViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

protocol SelectDemoTableViewModelDelegate: class {
	func selecDemoTableViewModel(didSelect demo: Demo)
}

class SelectDemoTableViewModel: NSObject, TableViewModel {
	
	let demos = [
		Demo.hotelQuery(),
		Demo.multiPolygonQuery()
	]
	
	private lazy var cellViewModels: [SelectableCellViewModel] = demos.map { demo in
		let cellViewModel = SelectableCellViewModel(title: demo.title)

		cellViewModel.selectionHandler = { [weak self] in
			self?.delegate?.selecDemoTableViewModel(didSelect: demo)
		}
		return cellViewModel
	}
	
	let cellViewModelTyes: [CellRepresentable.Type] = [
		SelectableCellViewModel.self
	]
	
	var reloadData: (() -> Void)?
	weak var delegate: SelectDemoTableViewModelDelegate?
	
	func registerCells(tableView: UITableView) {
		for cellViewModelType in cellViewModelTyes {
			cellViewModelType.registerCell(tableView: tableView)
		}
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		cellViewModels.count
	}
	
	func getCellViewModel(at indexPath: IndexPath) -> CellRepresentable {
		let row = indexPath.row
		return cellViewModels[row]
	}
	
	func handleCellSelection(at indexPath: IndexPath) {
		let row = indexPath.row
		cellViewModels[row].handleCellSelection()
	}
}
