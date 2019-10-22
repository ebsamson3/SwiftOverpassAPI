//
//  MainViewController.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import MapKit

class DemoViewController: UIViewController {
	
	let minPortraitHeight: CGFloat = 44
	let maxPortraitHeight: CGFloat = 300
	let landscapeFrame = CGRect(x: 16, y: 16, width: 250, height: 300)
	
	private lazy var mapViewController = MapViewController(
		viewModel: viewModel.mapViewModel
	)
	
	private lazy var tableViewController = TableViewController(
		viewModel: viewModel.tableViewModel)
	
	private lazy var pullUpContainer: PullUpContainer = {
		
		let pullUpContainer = PullUpContainer(
			contentViewController: tableViewController)
		
		pullUpContainer.headerViewHeight = minPortraitHeight
		pullUpContainer.minPortraitHeight = minPortraitHeight
		pullUpContainer.maxPortraitHeight = maxPortraitHeight
		pullUpContainer.landscapeFrame = landscapeFrame
		pullUpContainer.delegate = self
		return pullUpContainer
	}()
	
	private let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.hidesWhenStopped = true
		spinner.style = .large
		return spinner
	}()
	
	private let loadingLabel: UILabel = {
		let label = UILabel()
		label.text = "Fetching results..."
		return label
	}()
	
	let viewModel: DemoViewModel
	
	init(viewModel: DemoViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		viewModel.loadingStatusDidChangeTo = { [weak self] isLoading in
			if isLoading {
				self?.navigationItem.titleView = self?.loadingLabel
				self?.loadingLabel.sizeToFit()
				self?.spinner.startAnimating()
			} else {
				self?.navigationItem.titleView = nil
				self?.spinner.stopAnimating()
			}
		}
		
		viewModel.run()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard let status = pullUpContainer.status else {
			return
		}
		pullUpContainer(statusDidChangeTo: status)
	}
	
	private func configure() {
		addChild(mapViewController)
		mapViewController.didMove(toParent: self)

		_ = mapViewController.view
		let mapView = mapViewController.mapView
		view.addSubview(mapView)
		mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		addPullUpContainer(pullUpContainer)
		
		view.addSubview(spinner)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
	}
}

extension DemoViewController: PullUpContainerDelegate {
	func pullUpContainer(statusDidChangeTo status: PullUpContainer.Status) {
		switch status {
		case .portrait(let height):
			if height == maxPortraitHeight || height == minPortraitHeight  {
				let edgeInsets = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: height,
					right: 0)
				mapViewController.setEdgeInsets(to: edgeInsets)
			} 
		case .landscape:
			let edgeInsets = UIEdgeInsets(
				top: 0,
				left: landscapeFrame.origin.x + landscapeFrame.width + view.layoutMargins.left,
				bottom: 0,
				right: 0)
			mapViewController.setEdgeInsets(to: edgeInsets)
		}
	}
}
