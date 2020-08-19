//
//  OPBoundingBox.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// The 4 corner coordinates the define a search are of an Overpass API request.
public struct OPBoundingBox {
	
	public let minLatitude: Double
	public let minLongitude: Double
	public let maxLatitude: Double
	public let maxLongitude: Double
	
	public init(
		minLatitude: Double,
		minLongitude: Double,
		maxLatitude: Double,
		maxLongitude: Double
	)
	{
		self.minLatitude = minLatitude
		self.minLongitude = minLongitude
		self.maxLatitude = maxLatitude
		self.maxLongitude = maxLongitude
	}
	
	public func toString() -> String {
		
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
extension OPBoundingBox {
	
	// Creating from a mapkit region
	public init(region: MKCoordinateRegion) {
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
