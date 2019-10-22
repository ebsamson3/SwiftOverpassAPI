//
//  BoundingBox.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// The 4 corner coordinates the define a search are of an Overpass API request.
struct BoundingBox {
	
	let minLatitude: Double
	let minLongitude: Double
	let maxLatitude: Double
	let maxLongitude: Double
	
	func toString() -> String {
		
		let commaSeparatedValues = [
			minLatitude,
			minLongitude,
			maxLatitude,
			maxLongitude
		]
		.map {
			String($0)
		}
		.joined(separator: ",")
		
		return "(" + commaSeparatedValues + ")"
	}
}

// Convinience functions for creating a bounding box
extension BoundingBox {
	
	init(
		topLeftCoordinate: CLLocationCoordinate2D,
		bottomeRightCoordinate: CLLocationCoordinate2D)
	{
		minLatitude = bottomeRightCoordinate.latitude
		minLongitude = topLeftCoordinate.longitude
		maxLatitude = topLeftCoordinate.latitude
		maxLongitude = bottomeRightCoordinate.longitude
	}
	
	// Creating from a mapkit region
	init(region: MKCoordinateRegion) {
		let center = region.center
		let latitude = center.latitude
		let longitude = center.longitude
		let latitudeDelta = region.span.latitudeDelta
		let longitudeDelta = region.span.longitudeDelta
		
		minLatitude = latitude  - latitudeDelta / 2
		maxLatitude = latitude  + latitudeDelta / 2
		
		let minLongitude = longitude - longitudeDelta / 2
		
		// Preventing errors that may occur if the bounding box crosses the 180 degrees longitude line
		if minLongitude < -180 {
			self.minLongitude = 360 - minLongitude
		} else {
			self.minLongitude = minLongitude
		}
		
		let maxLongitude = longitude + longitudeDelta / 2
		
		// Preventing errors that may occur if the bounding box crosses the 180 degrees longitude line
		if maxLongitude > 180 {
			self.maxLongitude = maxLongitude - 360
		} else {
			self.maxLongitude = maxLongitude
		}
	}
}
