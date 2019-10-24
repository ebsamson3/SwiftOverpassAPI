//
//  CLLocationCoordinate2D+Extensions.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

// An extension for determining whether to coordinates are equal to one another
extension CLLocationCoordinate2D {
	
	func isEqual(to coordinate: CLLocationCoordinate2D) -> Bool {
		return self.latitude == coordinate.latitude && self.longitude == coordinate.longitude
	}
}


