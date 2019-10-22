//
//  ElementsController.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//
//
//import MapKit
//
//class OverpassController {
//
//	private let client = OverpassClient() // Client for Overpass API request
//	private var elements = [Int: Element]() // Stored elements from last successful request
//	private var query: String? // Overpass api request code
//
//	// Fetch elements for a specific query
//	func fetchElements(
//		query: String,
//		completion: @escaping (Result<[Int: Element]>) -> Void = {_ in })
//	{
//
//		// Clean up any results/operations from the previous request.
//		self.query = query
//		self.elements.removeAll()
//		client.cancelFetch()
//
//
//		client.fetchElements(query: query) { [weak self] result in
//
//			// If a new query has been initiated since the previous query returned, disregard the old query.
//			guard self?.query == query else {
//				return
//			}
//
//			// Handle results with a completion handler. Also store the elements w/in the controller itself.
//			switch result {
//			case .failure(let error):
//				completion(.failure(error))
//			case .success(let elements):
//				self?.elements = elements
//				completion(.success(elements))
//			}
//		}
//	}
//
//	// Returns elements stored in overpass controller
//	func getCurrentElements() -> [Int: Element] {
//		return elements
//	}
//
//	// Returns an element with a specific Id if stored in the overpass controller
//	func getElement(withId id: Int) -> Element? {
//		return elements[id]
//	}
//
//	// Returns mapkit visualizatiosn of all objects stored in the overpass controller
//	func mapKitVisualizationsForElements() -> [Int: OPMapKitVisualization] {
//		return VisualizationGenerator.mapKitVisualizations(forElements: elements)
//	}
//
//	// Returns mapkit visualizations for a specific element stored w/in the overpass controller
//	func mapKitVisualization(forElementWithId id: Int) -> OPMapKitVisualization? {
//		guard let element = elements[id] else {
//			return nil
//		}
//		return VisualizationGenerator.mapKitVisualization(forElement: element)
//	}
//}
