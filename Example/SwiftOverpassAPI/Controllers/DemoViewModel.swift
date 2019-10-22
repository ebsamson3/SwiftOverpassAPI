//
//  MainViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

class DemoViewModel {
	
	let demo: Demo
	let elementsController: ElementsController
	
	let mapViewModel = DemoMapViewModel()
	var loadingStatusDidChangeTo: ((_ isLoading: Bool) -> Void)?
	//var regionThatFits: ((MKCoordinateRegion) -> MKCoordinateRegion)?
	
	lazy var tableViewModel: DemoTableViewModel = {
		let tableViewModel = DemoTableViewModel(demo: demo)
		tableViewModel.delegate = self
		return tableViewModel
	}()
	
	init(demo: Demo, elementsController: ElementsController) {
		self.demo = demo
		self.elementsController = elementsController
	//	run()
	}
	
	func run() {
		
		loadingStatusDidChangeTo?(true)
		
		let region = demo.region
		
//		guard let queryRegion = regionThatFits?(region) else {
//			return
//		}
		
		let queryRect = region.toMKMapRect()
		let visualRect = queryRect.insetBy(dx: queryRect.width * 0.25, dy: queryRect.height * 0.25)
		let visualRegion = MKCoordinateRegion(visualRect)
		
		mapViewModel.region = visualRegion
		
		let query = demo.generateQuery(forRegion: region)
		
		elementsController.fetchElements(query: query) { result in
			switch result {
			case .failure(let error):
				print(error.localizedDescription)
			case .success(let elements):
				self.tableViewModel.generateViewModels(forElements: elements)
				let visualizations = self.elementsController.annotationsForElements()
				self.mapViewModel.addVisualizations(visualizations)
				self.loadingStatusDidChangeTo?(false)
			}
		}
	}
}

extension DemoViewModel: DemoTableViewModelDelegate {
	func didSelectCell(forElementWithId id: Int) {
		mapViewModel.centerMap(onVisualizationWithId: id)
		
		let element = elementsController.getElement(withId: id)
		
		if let tags = element?.tags {
			print("Selected element with tags: \(tags)")
		}
	}
}
