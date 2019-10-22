//
//  MainViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit
import SwiftOverpassAPI

class DemoViewModel {
	
	let demo: Demo
	let overpassClient: OverpassClient
	
	let mapViewModel = DemoMapViewModel()
	var loadingStatusDidChangeTo: ((_ isLoading: Bool) -> Void)?
	var elements = [Int: Element]()
	
	lazy var tableViewModel: DemoTableViewModel = {
		let tableViewModel = DemoTableViewModel(demo: demo)
		tableViewModel.delegate = self
		return tableViewModel
	}()
	
	init(demo: Demo, overpassClient: OverpassClient) {
		self.demo = demo
		self.overpassClient = overpassClient
	}
	
	func run() {
		
		loadingStatusDidChangeTo?(true)
		
		let region = demo.region
		
		let queryRect = region.toMKMapRect()
		let visualRect = queryRect.insetBy(dx: queryRect.width * 0.25, dy: queryRect.height * 0.25)
		let visualRegion = MKCoordinateRegion(visualRect)
		
		mapViewModel.region = visualRegion
		
		let query = demo.generateQuery(forRegion: region)
		
		overpassClient.fetchElements(query: query) { result in
			switch result {
			case .failure(let error):
				print(error.localizedDescription)
			case .success(let elements):
				self.elements = elements
				self.tableViewModel.generateViewModels(forElements: elements)
				let visualizations = VisualizationGenerator
					.mapKitVisualizations(forElements: elements)
				self.mapViewModel.addVisualizations(visualizations)
				self.loadingStatusDidChangeTo?(false)
			}
		}
	}
}

extension DemoViewModel: DemoTableViewModelDelegate {
	func didSelectCell(forElementWithId id: Int) {
		mapViewModel.centerMap(onVisualizationWithId: id)
		
		if let tags = elements[id]?.tags {
			print("Selected element with tags: \(tags)")
		}
	}
}
