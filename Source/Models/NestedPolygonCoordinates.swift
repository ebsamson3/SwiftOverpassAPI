//
//  NestedPolygonGeometry.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/14/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

// Used to store the coordinates for a nested polygon structure. The outer ring contains the coordinates for a single outer polygon. The inner ring contains the coordinates for any number of interior polygons. 
public struct NestedPolygonCoordinates {
	let outerRing: [CLLocationCoordinate2D]
	let innerRings: [[CLLocationCoordinate2D]]
}
