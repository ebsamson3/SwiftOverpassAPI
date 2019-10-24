//
//  CellRepresentable.swift
//  SwiftOverpassAPI_Example
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

// Protocol for a cell view model that can register that cell's class and instantiate it's own cell
protocol CellRepresentable {
	static func registerCell(tableView: UITableView)
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}

