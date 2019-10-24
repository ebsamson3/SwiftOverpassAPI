//
//  DemoViewController.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import MapKit

// Main view controller for running various overpass API demos
class DemoViewController: UIViewController {
	
	// Max and min heights above for the pull up container view while the device is in portrait orientation
	lazy var minPortraitHeight: CGFloat = 44
	lazy var maxPortraitHeight: CGFloat = {
		let bounds = UIScreen.main.bounds
		let maxDimension = max(bounds.width, bounds.height)
		return maxDimension * 0.4
	}()
	
	// Frame of the pull up container while the device is in landscape orientation.
	let landscapeFrame = CGRect(x: 16, y: 16, width: 250, height: 300)
	

	// DemoViewController has two main child view controllers, a MapViewController and a TableViewController. This is mirrored by the DemoViewController's view model, which has two child view models: a MapViewModel and a TableViewModel.
	private lazy var mapViewController = MapViewController(
		viewModel: viewModel.mapViewModel
	)
	private lazy var tableViewController = TableViewController(
		viewModel: viewModel.tableViewModel)
	
	// The table view controller is placed inside of a custom container view controller that enables the tableview to be pulled up from the bottom of the screen.
	private lazy var pullUpContainer: PullUpContainer = {
		
		// Embed the tableViewController inside the pull up controller
		let pullUpContainer = PullUpContainer(
			contentViewController: tableViewController)
		
		// Configuring the pull up container's dimensions after initialization
		pullUpContainer.headerViewHeight = minPortraitHeight
		pullUpContainer.minPortraitHeight = minPortraitHeight
		pullUpContainer.maxPortraitHeight = maxPortraitHeight
		pullUpContainer.landscapeFrame = landscapeFrame
		
		// Setting the pull up container delegate to the DemoViewController
		pullUpContainer.delegate = self
		
		// Return the pull up container after it has been configured
		return pullUpContainer
	}()
	
	// A spinner for indicating that an Overpass query is in progress
	private let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.hidesWhenStopped = true
		spinner.style = .large
		return spinner
	}()
	
	// While loading, change the navigation bar title to "Fetching results..."
	private let loadingLabel: UILabel = {
		let label = UILabel()
		label.text = "Fetching results..."
		return label
	}()
	
	// Button for resetting the mapView's region
	private lazy var resetMapViewButton = UIBarButtonItem(
			title: "Reset",
			style: UIBarButtonItem.Style.plain,
			target: self, action: #selector(resetMapViewRegion(sender:)))
	
	// The DemoViewController's main view model
	let viewModel: DemoViewModel
	
	// Initialize the view controller with a demo view model
	init(viewModel: DemoViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		// Connecting the navigation bar title and activity spinner animation to the loading status of the view model
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
		
		// After configuring the view model we run it.
		viewModel.run()
	}
	
	// Required boilerplate
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// Configure the view constraints on view did load
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}
	
	// Once the view has appeared, run pullUpContainer(statudDidChange:) to adjust the map view content so that it isn't covered by the pull up container.
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard let status = pullUpContainer.status else {
			return
		}
		pullUpContainer(statusDidChangeTo: status)
	}
	
	private func configure() {
		// Add the mapViewController as a child view controller to demoViewController
		addChild(mapViewController)
		mapViewController.didMove(toParent: self)

		// Calls the viewDidLoad() method of the mapViewController
		_ = mapViewController.view
		
		// Add the view of the mapViewControlelr as a subview to the demoViewController's view and configure it's constraints.
		let mapView = mapViewController.mapView
		view.addSubview(mapView)
		mapViewController.view.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
		
		// Add button for reseting mapView to region to default query region
		navigationItem.rightBarButtonItem = resetMapViewButton
		
		// Add the pull up container as a child view controller to the demoViewController
		addPullUpContainer(pullUpContainer)
		
		// Lastly, add the spinner as a subview to the demoViewController's view and setup it's constraints
		view.addSubview(spinner)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
		spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
	}
	
	// Handle resetting the mapView region
	@objc private func resetMapViewRegion(sender: UIButton) {
		viewModel.resetMapViewRegion()
	}
}

extension DemoViewController: PullUpContainerDelegate {
	
	// Called whenever the pullUpContainer's frame changes. Adjusts the mapView's content so that it is centered on the portion of the mapVeiw that isn't covered by the pullUpContainer.
	func pullUpContainer(statusDidChangeTo status: PullUpContainer.Status) {
		switch status {
		case .portrait(let height):
			if height == maxPortraitHeight || height == minPortraitHeight  {
				let edgeInsets = UIEdgeInsets(
					top: 0,
					left: 0,
					bottom: height - view.safeAreaInsets.bottom,
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
