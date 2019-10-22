//
//  TableViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

protocol TableViewModel: NSObject {
	var numberOfSections: Int { get}
	var reloadData: (() -> Void)? { get set }
	
	func registerCells(tableView: UITableView)
	func numberOfRows(inSection section: Int) -> Int
	func getCellViewModel(at indexPath: IndexPath) -> CellRepresentable
	func handleCellSelection(at indexPath: IndexPath)
}

extension TableViewModel {
	var numberOfSections: Int {
		return 1
	}
}
