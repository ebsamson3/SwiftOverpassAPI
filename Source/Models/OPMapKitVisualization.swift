//
//  OPMapKitVisualization.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/7/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

/*
	Mapkit visualization types for overpass elements. Different returned elements require different visualization types.
*/
public enum OPMapKitVisualization {
	case annotation(MKAnnotation)
	case polygon(MKPolygon)
	case polyline(MKPolyline)
	case polygons([MKPolygon])
	case polylines([MKPolyline])
}
