//
//  Demo.swift
//  SwiftOverpassAPI_Example
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit
import SwiftOverpassAPI

// A struct for storing information required to define an Overpass API demo.
struct Demo {
	let title: String
	let resultUnit: String // Generic name for a query's result
	let defaultRegion: MKCoordinateRegion // Default query region
	
	// Takes a region and returns a query
	private let queryGenerator: (MKCoordinateRegion) -> String
	
	// Runs the query generation handler
	func generateQuery(forRegion region: MKCoordinateRegion) -> String {
		return queryGenerator(region)
	}
}

// Convinience functions for creating demo instances
extension Demo {

	static func makeHotelQuery() -> Demo {

		let title = "St. Louis hotels"
		let resultUnit = "Hotel"

		let stLouisCoordinate = CLLocationCoordinate2D(
			latitude: 38.6270,
			longitude: -90.1994)

		let region = MKCoordinateRegion(
			center: stLouisCoordinate,
			latitudinalMeters: 10000,
			longitudinalMeters: 10000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = OPBoundingBox.init(region: region)

			return try! OPQueryBuilder()
				.setElementTypes([.node, .way, .relation])
				.addTagFilter(key: "tourism", value: "hotel")
				.setBoundingBox(boundingBox)
				.setOutputType(.center)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			defaultRegion: region,
			queryGenerator: queryGenerator)
	}

	static func makeChicagoBuildingsQuery() -> Demo {

		let title = "Chicago buildings"
		let resultUnit = "Building"

		let chicagoCoordinate = CLLocationCoordinate2D(
			latitude: 41.8781,
			longitude: -87.6298)

		let region = MKCoordinateRegion(
			center: chicagoCoordinate,
			latitudinalMeters: 5000,
			longitudinalMeters: 5000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = OPBoundingBox.init(region: region)

			return try! OPQueryBuilder()
				.setTimeOut(180)
				.setElementTypes([.way, .relation])
				.addTagFilter(key: "building")
				.addTagFilter(key: "name")
				.setBoundingBox(boundingBox)
				.setOutputType(.geometry)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			defaultRegion: region,
			queryGenerator: queryGenerator)
	}
	
	static func makeChicagoTourismQuery() -> Demo {

		let title = "Chicago tourist attractions"
		let resultUnit = "Attraction"

		let chicagoCoordinate = CLLocationCoordinate2D(
			latitude: 41.8781,
			longitude: -87.6298)

		let region = MKCoordinateRegion(
			center: chicagoCoordinate,
			latitudinalMeters: 10000,
			longitudinalMeters: 10000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = OPBoundingBox.init(region: region)

			return try! OPQueryBuilder()
				.setTimeOut(180)
				.setElementTypes([.node, .way, .relation])
				.addTagFilter(key: "tourism")
				.setBoundingBox(boundingBox)
				.setOutputType(.center)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			defaultRegion: region,
			queryGenerator: queryGenerator)
	}
	
	static func makeSanFranciscoRoutesQuery() -> Demo {

		let title = "BART subway lines"
		let resultUnit = "Route"

		let sanFranciscoCoordinate = CLLocationCoordinate2D(
			latitude: 37.7749,
			longitude: -122.4194)

		let region = MKCoordinateRegion(
			center: sanFranciscoCoordinate,
			latitudinalMeters: 50000,
			longitudinalMeters: 50000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = OPBoundingBox.init(region: region)

			return try! OPQueryBuilder()
				.setTimeOut(180)
				.setElementTypes([.relation])
				.addTagFilter(key: "network", value: "BART")
				.addTagFilter(key: "type", value: "route")
				.setBoundingBox(boundingBox)
				.setOutputType(.geometry)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			defaultRegion: region,
			queryGenerator: queryGenerator)
	}
	
	static func theatresNearBARTStopsQuery() -> Demo {

		let title = "Theatres near BART stops"
		let resultUnit = "Theatre"

		let sanFranciscoCoordinate = CLLocationCoordinate2D(
			latitude: 37.7749,
			longitude: -122.4194)

		let region = MKCoordinateRegion(
			center: sanFranciscoCoordinate,
			latitudinalMeters: 50000,
			longitudinalMeters: 50000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = OPBoundingBox.init(region: region)

			return try! OPQueryBuilder()
				.setTimeOut(180)
				.setElementTypes([.relation])
				.addTagFilter(key: "network", value: "BART")
				.addTagFilter(key: "type", value: "route")
				.setBoundingBox(boundingBox)
				.setOutputType(.geometry)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			defaultRegion: region,
			queryGenerator: queryGenerator)
	}
}
