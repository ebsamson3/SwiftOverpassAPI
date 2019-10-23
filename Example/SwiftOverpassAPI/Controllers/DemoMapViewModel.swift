//
//  DemoMapViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit
import SwiftOverpassAPI

class DemoMapViewModel: NSObject, MapViewModel {
	
	// All MapKit Overpass Visualizations
	var visualizations = [Int: OPMapKitVisualization]()
	
	var annotations = [MKAnnotation]() // Annotations generated from center visualizations
	var overlays = [MKOverlay]() // Overlays generated from polygon/polyline type visualizations.
	
	// Variable for storing/setting the bound mapView's region
	var region: MKCoordinateRegion? {
		didSet {
			guard let region = region else { return }
			setRegion?(region)
		}
	}
	
	// Reuse identifier for marker annotation views. 
	private let markerReuseIdentifier = "MarkerAnnotationView"
	
	// Handler functions for set the bound mapView's region and adding/removing annotations and overlays
	var setRegion: ((MKCoordinateRegion) -> Void)?
	var addAnnotations: (([MKAnnotation]) -> Void)?
	var addOverlays: (([MKOverlay]) -> Void)?
	var removeAnnotations: (([MKAnnotation]) -> Void)?
	var removeOverlays: (([MKOverlay]) -> Void)?
	
	// Function to register all reusable annotation views to the mapView
	func registerAnnotationViews(to mapView: MKMapView) {
		mapView.register(
			MKPinAnnotationView.self,
			forAnnotationViewWithReuseIdentifier: markerReuseIdentifier)
	}
	
	// Convert visualizations to MapKit overlays and annoations
	func addVisualizations(_ visualizations: [Int: OPMapKitVisualization]) {
		
		self.visualizations = visualizations
		
		removeAnnotations?(annotations)
		removeOverlays?(overlays)
		annotations = []
		overlays = []
		
		var newAnnotations = [MKAnnotation]()
		var polylines = [MKPolyline]()
		var polygons = [MKPolygon]()
		
		// For each visualization, append it to annotations, polylines, or polygons array depending on it's type.
		for visualization in visualizations.values {
			switch visualization {
			case .annotation(let annotation):
				newAnnotations.append(annotation)
			case .polyline(let polyline):
				polylines.append(polyline)
			case .polylines(let newPolylines):
				polylines.append(contentsOf: newPolylines)
			case .polygon(let polygon):
				polygons.append(polygon)
			case .polygons(let newPolygons):
				polygons.append(contentsOf: newPolygons)
			}
		}
		
		// Create MultiPolygon and Multipolyline overlays for rendering all the polylgons and polylines respectively. This allows each polygon and polyline to share a renderer so that they can be efficiently displayed on the mapView.
		let multiPolyline = MKMultiPolyline(polylines)
		let multiPolygon = MKMultiPolygon(polygons)
		
		// Create an overlays array from the multiPolyline and multiPolygon
		let newOverlays: [MKOverlay] = [multiPolyline, multiPolygon]
		
		// Store the new annotations and overlays in their respective variables
		annotations = newAnnotations
		overlays = newOverlays
		
		// Add the annotaitons and overlays to the mapView
		addAnnotations?(annotations)
		addOverlays?(overlays)
	}
	
	// Function called to center the mapView on a particular visualization
	func centerMap(onVisualizationWithId id: Int) {
		guard let visualization = visualizations[id] else {
			return
		}
		
		let region: MKCoordinateRegion
		let insetRatio: Double = -0.25
		
		let boundingRects: [MKMapRect]
		
		// If the visualization is an annotation then center on the annotation's coordinate. Otherwise, find the bounding rectangles of every object in the visualization
		switch visualization {
		case .annotation(let annotation):
			region = MKCoordinateRegion(
				center: annotation.coordinate,
				latitudinalMeters: 500,
				longitudinalMeters: 500)
			self.region = region
			return
		case .polyline(let polyline):
			boundingRects = [polyline.boundingMapRect]
		case .polygon(let polygon):
			boundingRects = [polygon.boundingMapRect]
		case .polylines(let polylines):
			boundingRects = polylines.map { $0.boundingMapRect }
		case .polygons(let polygons):
			boundingRects = polygons.map { $0.boundingMapRect }
		}
		
		// Find a larger rectable that encompasses all the bounding rectangles for each individual object in the visualization.
		guard
			let minX = (boundingRects.map { $0.minX }).min(),
			let maxX = (boundingRects.map { $0.maxX }).max(),
			let minY = (boundingRects.map { $0.minY }).min(),
			let maxY = (boundingRects.map { $0.maxY }).max()
		else {
			return
		}
		let width = maxX - minX
		let height = maxY - minY
		let rect = MKMapRect(x: minX, y: minY, width: width, height: height)
		
		// Pad the large rectangle by the specified ratio
		let paddedRect = rect.insetBy(dx: width * insetRatio, dy: height * insetRatio)
		
		// Convert the rectangle to a MKCoordinateRegion
		region = MKCoordinateRegion(paddedRect)
		
		// Set the mapView region to the new visualization-emcompassing region
		self.region = region
	}
	
	// Renderers for various overlay types
	func renderer(for overlay: MKOverlay) -> MKOverlayRenderer {
		
		let strokeWidth: CGFloat = 2
		let strokeColor = UIColor.theme
		let fillColor = UIColor.theme.withAlphaComponent(0.5)
		
		if let polyline = overlay as? MKPolyline {
			let renderer = MKPolylineRenderer(polyline: polyline)
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else if let polygon = overlay as? MKPolygon {
			let renderer = MKPolygonRenderer(polygon: polygon)
			renderer.fillColor = fillColor
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		}	else if let multiPolyline = overlay as? MKMultiPolyline {
			let renderer = MKMultiPolylineRenderer(multiPolyline: multiPolyline)
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else if let multiPolygon = overlay as? MKMultiPolygon {
			let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon)
			renderer.fillColor = fillColor
			renderer.strokeColor = strokeColor
			renderer.lineWidth = strokeWidth
			return renderer
		} else {
			return MKOverlayRenderer()
		}
	}
	
	// Set the annotaiton view for annotations visualized on the mapView
	func view(for annotation: MKAnnotation) -> MKAnnotationView? {
		guard let pointAnnotation = annotation as? MKPointAnnotation else {
			return nil
		}
		let view = MKMarkerAnnotationView(
			annotation: pointAnnotation,
			reuseIdentifier: markerReuseIdentifier)
		
		view.markerTintColor = UIColor.theme
		return view
	}
	
	func userDidGestureOnMapView(sender: UIGestureRecognizer) {
		
		if
			sender.isKind(of: UIPanGestureRecognizer.self) ||
			sender.isKind(of: UIPinchGestureRecognizer.self)
		{
			region = nil
		}
	}
}
