//
//  OPVisualizationGenerator.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//


import MapKit

public struct OPVisualizationGenerator {
	
	// Pass in an array of decoded overpass objects to get their respective mapkit visualizations (annotations and polygons, depending on object type).
	
	public static func mapKitVisualizations(
		forElements elements: [Int: OPElement]) -> [Int: OPMapKitVisualization]
	{
		
		// For each key: Overpass ID and value: Decodeded Overpass Element
		
		return Dictionary(uniqueKeysWithValues: elements.compactMap({ (id, element) in
			
			// Avoids generating visualizations for uninteresting overpass elements (for example, annonymous nodes that make up a way/relation that is already being generated.
			guard element.isInteresting else {
				return nil
			}
			
			// Avoid generating visualizations for elements that have already been rendered as a member of a parent element.
			guard !element.isSkippable else {
				return nil
			}
			
			// Generate mapkit visualization
			guard let annotation = mapKitVisualization(forElement: element) else {
				return nil
			}
			
			// Return visualization with same key as specified in input dictionary. Typically this is the ID for the overpass element being visualized.
			return (id, annotation)
		}))
	}
	
	// Generates a mapkit visualization for a given decoded overpass element
	public static func mapKitVisualization(forElement element: OPElement) -> OPMapKitVisualization? {
		
		// Different element geometries require different classes of mapkit visualizations
		switch element.geometry {
		case .none:
			return nil
		case .center(let coordinate):
			// Single coordinate geometries are rendered as annotations
			let annotation = MKPointAnnotation()
			annotation.coordinate = coordinate
			annotation.title = element.tags[Overpass.Keys.name]
			return .annotation(annotation)
		case .polyline(let coordinates):
			// Unclosed coordinate arrays are rendered as polylines
			let polyline = MKPolyline(
				coordinates: coordinates,
				count: coordinates.count)
			polyline.title = element.tags[Overpass.Keys.name]
			return .polyline(polyline)
		case .polygon(let coordinates):
			// Close coordinate arrays are rendered as polygons
			let polygon = MKPolygon(
				coordinates: coordinates,
				count: coordinates.count)
			polygon.title = element.tags[Overpass.Keys.name]
			return .polygon(polygon)
		case .multiPolyline(let coordinatesArray):
			// Multiple unclosed arrays of coordinates (for example, a collection of streets) are converted into an array of polylines
			let polylines = coordinatesArray.map {
				MKPolyline(coordinates: $0, count: $0.count)
			}
			return .polylines(polylines)
		case .multiPolygon(let nestedPolygonCoordinatesArray):
			//Multiple nested polygon coordinate arrays (typically buildings made up of multiple polygons) are converted into an array of polygons.
			
			// For each nested coordinate array (a single outer ring containing any number of inner rings). Rings being any closed array of coorinate.
			let polygons: [MKPolygon] = nestedPolygonCoordinatesArray.map {
				
				// Generate polygons for the inner rings
				let innerPolygons = $0.innerRings.map { coordinates in
					MKPolygon(
						coordinates: coordinates,
						count: coordinates.count)
				}
				
				// Create the outer polygon and set all the inner polygons in the nested coordinate array as interior polygons. 
				return MKPolygon(
					coordinates: $0.outerRing,
					count: $0.outerRing.count,
					interiorPolygons: innerPolygons)
			}
			
			return .polygons(polygons)
		}
	}
}
