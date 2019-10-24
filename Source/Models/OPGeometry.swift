//
//  OPGeometry.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/13/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

/*
	The types of geometries an element can have, represented in coordinates, a collection of coordinates, or in collections of coordinate collections. For example, a point of interest.
	Center: A single coordinate, or latitude/longitude pair.
	Polyline: An array of coordinates that form a polyline, or a collection of lines connected end-to-end. For example, a road.
	Polygon: Similar to a polyline except the first and last coordinates are the same. This is rendered as a closed polygon. For example, a building.
	Multipolygon: A collection of nested polygons. This can be used to create complicated clusters of polygons with internal voids. For example, a baseball statium.
	Multipolyline: A collection of polylines. For example, a collection of roads that make up the routes of a city's public transportation system.
*/

public enum OPGeometry {
	case center(CLLocationCoordinate2D)
	case polyline([CLLocationCoordinate2D])
	case polygon([CLLocationCoordinate2D])
	case multiPolygon([NestedPolygonCoordinates])
	case multiPolyline([[CLLocationCoordinate2D]])
	case none
}
