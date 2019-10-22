//
//  DemoMapViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

class DemoMapViewModel: NSObject, MapViewModel {
	
	var visualizations = [Int: AGResult]()
	var annotations = [MKAnnotation]()
	var overlays = [MKOverlay]()
	
	var region: MKCoordinateRegion? {
		didSet {
			guard let region = region else { return }
			setRegion?(region)
		}
	}
	
	private let pinReuseIdentifier = "PinAnnotationView"
	private let themeColor = UIColor.blue
	
	var setRegion: ((MKCoordinateRegion) -> Void)?
	var addAnnotations: (([MKAnnotation]) -> Void)?
	var addOverlays: (([MKOverlay]) -> Void)?
	var removeAnnotations: (([MKAnnotation]) -> Void)?
	var removeOverlays: (([MKOverlay]) -> Void)?
	
	func registerAnnotationViews(to mapView: MKMapView) {
		mapView.register(
			MKPinAnnotationView.self,
			forAnnotationViewWithReuseIdentifier: pinReuseIdentifier)
	}
	
	func addVisualizations(_ visualizations: [Int: AGResult]) {
		
		self.visualizations = visualizations
		
		removeAnnotations?(annotations)
		removeOverlays?(overlays)
		annotations = []
		overlays = []
		
		var newAnnotations = [MKAnnotation]()
		var polylines = [MKPolyline]()
		var polygons = [MKPolygon]()
		
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
		
		let multiPolyline = MKMultiPolyline(polylines)
		let multiPolygon = MKMultiPolygon(polygons)
		let newOverlays: [MKOverlay] = [multiPolyline, multiPolygon]
		
		annotations = newAnnotations
		overlays = newOverlays
		
		addAnnotations?(annotations)
		addOverlays?(overlays)
	}
	
	func centerMap(onVisualizationWithId id: Int) {
		guard let visualization = visualizations[id] else {
			return
		}
		
		let region: MKCoordinateRegion

		switch visualization {
		case .annotation(let annotation):
			region = MKCoordinateRegion(
				center: annotation.coordinate,
				latitudinalMeters: 500,
				longitudinalMeters: 500)
		case .polyline(let polyline):
			let rect = polyline.boundingMapRect
			let width = rect.width
			let height = rect.height
			let paddedRect = rect.insetBy(dx: width * -0.25, dy: height * -0.25)
			region = MKCoordinateRegion(paddedRect)
		case .polygon(let polygon):
			let rect = polygon.boundingMapRect
			let width = rect.width
			let height = rect.height
			let paddedRect = rect.insetBy(dx: width * -0.25, dy: height * -0.25)
			region = MKCoordinateRegion(paddedRect)
		case .polylines(let polylines):
			let boundingRects = polylines.map { $0.boundingMapRect }
			
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
			let paddedRect = rect.insetBy(dx: width * -0.25, dy: height * -0.25)
			region = MKCoordinateRegion(paddedRect)
		case .polygons(let polygons):
			let boundingRects = polygons.map { $0.boundingMapRect }
			
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
			let paddedRect = rect.insetBy(dx: width * -0.25, dy: height * -0.25)
			region = MKCoordinateRegion(paddedRect)
		}
		
		self.region = region
	}
	
	func renderer(for overlay: MKOverlay) -> MKOverlayRenderer {
		
		let strokeWidth: CGFloat = 2
		let strokeColor = themeColor
		let fillColor = themeColor.withAlphaComponent(0.5)
		
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
	
	func view(for annotation: MKAnnotation) -> MKAnnotationView? {
		guard let pointAnnotation = annotation as? MKPointAnnotation else {
			return nil
		}
		let view = MKMarkerAnnotationView(
			annotation: pointAnnotation,
			reuseIdentifier: pinReuseIdentifier)
		
		view.markerTintColor = themeColor
		
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
