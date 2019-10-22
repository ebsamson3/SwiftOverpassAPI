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

class DemoTableViewModel: NSObject, TableViewModel {
	
	private var cellViewModels = [SelectableCellViewModel]()
	
	private var cellViewModelTypes: [CellRepresentable.Type] = [
		SelectableCellViewModel.self
	]
	
	var reloadData: (() -> Void)?
	weak var delegate: DemoTableViewModelDelegate?
	
	let demo: Demo
	
	init(demo: Demo) {
		self.demo = demo
	}
	
	func registerCells(tableView: UITableView) {
		for cellViewModelType in cellViewModelTypes {
			cellViewModelType.registerCell(tableView: tableView)
		}
	}
	
	func numberOfRows(inSection section: Int) -> Int {
		return cellViewModels.count
	}
	
	func getCellViewModel(at indexPath: IndexPath) -> CellRepresentable {
		let row = indexPath.row
		return cellViewModels[row]
	}
	
	func handleCellSelection(at indexPath: IndexPath) {
		let row = indexPath.row
		cellViewModels[row].selectionHandler?()
	}
	
	func generateViewModels(forElements elements: [Int: Element]) {
		
		DispatchQueue.global(qos: .userInitiated).async { [weak self] in
			
			guard let demo = self?.demo else {
				return
			}
			
			let numberFormatter = NumberFormatter()
			let minimumIntegerDigits = String(elements.count).count
			numberFormatter.minimumIntegerDigits = minimumIntegerDigits
			
			var newCellViewModels = [SelectableCellViewModel]()
			var counter = 1
			
			for (id, element) in elements {
				
				guard element.isInteresting && !element.isSkippable else {
					continue
				}
				
				let title: String
				
				if let elementName = element.tags["name"] {
					title = elementName
				} else {
					let counterValue = NSNumber(value: counter)
					
					guard
						let numberString = numberFormatter.string(from: counterValue)
					else {
						continue
					}
					
					title = "Untitled \(demo.resultUnit) \(numberString)"
					counter += 1
				}
				
				let cellViewModel = SelectableCellViewModel(title: title)
				
				cellViewModel.selectionHandler = {
					self?.delegate?.didSelectCell(forElementWithId: id)
				}
				
				newCellViewModels.append(cellViewModel)
			}
			
			newCellViewModels.sort { (viewModel1, viewModel2) in
				viewModel1.title < viewModel2.title
			}
			
			DispatchQueue.main.async {
				self?.cellViewModels = newCellViewModels
				self?.reloadData?()
			}
		}
	}
}
