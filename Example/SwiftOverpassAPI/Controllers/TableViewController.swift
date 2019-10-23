//
//  TableViewController.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

// A basic MVVM TableViewController 
class TableViewController: UIViewController {
	
	let viewModel: TableViewModel
	
	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.delegate = self
		tableView.dataSource = self
		return tableView
	}()
	
	init(viewModel: TableViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		viewModel.reloadData = { [weak self] in
			self?.tableView.reloadData()
		}
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
		viewModel.registerCells(tableView: tableView)
	}
	
	// Configure the tableView's constaints
	private func configure() {
		view.addSubview(tableView)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.topAnchor.constraint(
			equalTo: view.topAnchor)
			.isActive = true
		tableView.trailingAnchor.constraint(
			equalTo: view.trailingAnchor)
			.withPriority(.defaultHigh)
			.isActive = true
		tableView.bottomAnchor.constraint(
			equalTo: view.bottomAnchor)
			.withPriority(.defaultHigh)
			.isActive = true
		tableView.leadingAnchor.constraint(
			equalTo: view.leadingAnchor)
			.isActive = true
	}
}

extension TableViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return viewModel.numberOfSections
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModel.numberOfRows(inSection: section)
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cellViewModel = viewModel.getCellViewModel(at: indexPath)
		let cell = cellViewModel.cellInstance(tableView: tableView, indexPath: indexPath)
		return cell
	}
}

extension TableViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		viewModel.handleCellSelection(at: indexPath)
	}
}
