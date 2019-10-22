//
//  Demo.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/8/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit
import SwiftOverpassAPI

struct Demo {
	let title: String
	let resultUnit: String
	let region: MKCoordinateRegion
	private let queryGenerator: (MKCoordinateRegion) -> String
	
	func generateQuery(forRegion region: MKCoordinateRegion) -> String {
		return queryGenerator(region)
	}
}

extension Demo {

	static func hotelQuery() -> Demo {

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

			let boundingBox = BoundingBox.init(region: region)

			return try! OverpassQueryBuilder()
				.setElementTypes([.node, .way, .relation])
				.addTagFilter(key: "tourism", value: "hotel")
				.setBoundingBox(boundingBox)
				.setOutputType(.center)
				.buildQueryString()
		}

		return Demo(
			title: title,
			resultUnit: resultUnit,
			region: region,
			queryGenerator: queryGenerator)
	}

	static func multiPolygonQuery() -> Demo {

		let title = "Chicago buildings"
		let resultUnit = "Building"

		let stLouisCoordinate = CLLocationCoordinate2D(
			latitude: 41.8781,
			longitude: -87.6298)

		let region = MKCoordinateRegion(
			center: stLouisCoordinate,
			latitudinalMeters: 5000,
			longitudinalMeters: 5000)

		let queryGenerator: (MKCoordinateRegion) -> String = { region in

			let boundingBox = BoundingBox.init(region: region)

			return try! OverpassQueryBuilder()
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
			region: region,
			queryGenerator: queryGenerator)
	}
}
