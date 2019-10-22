//
//  CellRepresentable.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

protocol CellRepresentable {
	static func registerCell(tableView: UITableView)
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}

