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

// A view model for a simple demo selection tableView
class SelectDemoTableViewModel: NSObject, TableViewModel {
	
	// An array of demo objects
	let demos = [
		Demo.makeHotelQuery(),
		Demo.makeChicagoBuildingsQuery(),
		Demo.makeChicagoTourismQuery(),
		Demo.makeSanFranciscoRoutesQuery()
	]
	
	// Initializing a simple selectable cellViewModel for each demo. The title is the corresponding demo's title.
	private lazy var cellViewModels: [SelectableCellViewModel] = demos.map { demo in
		let cellViewModel = SelectableCellViewModel(title: demo.title)

		// The selection handler of the cellViewModel notifies the delegate that the corresponding demo was selected.
		cellViewModel.selectionHandler = { [weak self] in
			self?.delegate?.selecDemoTableViewModel(didSelect: demo)
		}
		return cellViewModel
	}
	
	// An array holding all relavant cellViewModel types. Cell representable is the protocol cellViewModels must conform to.
	let cellViewModelTyes: [CellRepresentable.Type] = [
		SelectableCellViewModel.self
	]
	
	// The handler that gets called when the bound tableView needs to be reloaded
	var reloadData: (() -> Void)?
	
	weak var delegate: SelectDemoTableViewModelDelegate?
	
	// Register all relevant table view cell types using the static function in each cellViewModel type.
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
	
	// When a cell is selected, call the corresponding cellViewModel's selection handler.
	func handleCellSelection(at indexPath: IndexPath) {
		let row = indexPath.row
		cellViewModels[row].handleCellSelection()
	}
}
