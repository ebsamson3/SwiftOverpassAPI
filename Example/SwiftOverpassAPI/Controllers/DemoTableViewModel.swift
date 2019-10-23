//
//  DemoTableViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/15/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import SwiftOverpassAPI

protocol DemoTableViewModelDelegate: class {
	func didSelectCell(forElementWithId id: Int)
}

// A view model for a tableView that displays the names of Overpass elements
class DemoTableViewModel: NSObject, TableViewModel {
	
	// A simple selectable cell view model class
	private var cellViewModels = [SelectableCellViewModel]()
	
	// An array holding all relavant cellViewModel types. Cell representable is the protocol cellViewModels must conform to.
	private var cellViewModelTypes: [CellRepresentable.Type] = [
		SelectableCellViewModel.self
	]
	
	// The handler that is called whenever the bound tableView needs to reload.
	var reloadData: (() -> Void)?
	
	weak var delegate: DemoTableViewModelDelegate?
	
	let demo: Demo
	
	init(demo: Demo) {
		self.demo = demo
	}
	
	// Register all relevant table view cell types using the static function in each cellViewModel type.
	func registerCells(tableView: UITableView) {
		for cellViewModelType in cellViewModelTypes {
			cellViewModelType.registerCell(tableView: tableView)
		}
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return cellViewModels.count
	}
	
	// Use the cellViewModel instances to generate the corresponding cell instances.
	func getCellViewModel(at indexPath: IndexPath) -> CellRepresentable {
		let row = indexPath.row
		return cellViewModels[row]
	}
	
	// Call the selection handler of the cellViewModel that corresponds to the selected cell.
	func handleCellSelection(at indexPath: IndexPath) {
		let row = indexPath.row
		cellViewModels[row].selectionHandler?()
	}
	
	// Generate cellViewModels for each element
	func generateCellViewModels(forElements elements: [Int: Element]) {
		
		// Perform cellViewModel generation off the main thread to keep UI responsive
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			
			guard let demo = self?.demo else {
				return
			}
			
			// Untitled elements are given generic name followed by a unique number. We use a number formatter to format the number of digits in the number string.
			let numberFormatter = NumberFormatter()
			let minimumIntegerDigits = String(elements.count).count
			numberFormatter.minimumIntegerDigits = minimumIntegerDigits
			
			// Array that stores the cellViewModels that will be added
			var newCellViewModels = [SelectableCellViewModel]()
			
			var counter = 1
			
			// For each element
			for (id, element) in elements {
				
				// If the element is interesting and not skippable
				guard element.isInteresting && !element.isSkippable else {
					continue
				}
				
				
				let title: String
				
				if let elementName = element.tags["name"] {
					// If the name tage has a value, set the cell title to that name
					title = elementName
				} else {
					
					let counterValue = NSNumber(value: counter)
					
					guard
						let numberString = numberFormatter.string(from: counterValue)
					else {
						continue
					}
					
					// Otherwise use the generic name supplied by the demo object plus an incrementing number identifier
					title = "Untitled \(demo.resultUnit) \(numberString)"
					counter += 1
				}
				
				// Generate the cellViewModel
				let cellViewModel = SelectableCellViewModel(title: title)
				
				// Set the selection handler of the cellViewModel so that it calls the delegate method of the tableViewModel
				cellViewModel.selectionHandler = {
					self?.delegate?.didSelectCell(forElementWithId: id)
				}
				
				newCellViewModels.append(cellViewModel)
			}
			
			// Sort the cellViewModels by name
			newCellViewModels.sort { (viewModel1, viewModel2) in
				viewModel1.title < viewModel2.title
			}
			
			// Switch back to the main thread and set the cellViewModels array to the new cellViewModels. Notify the tableView that it should reload. 
			DispatchQueue.main.async {
				self?.cellViewModels = newCellViewModels
				self?.reloadData?()
			}
		}
	}
}
