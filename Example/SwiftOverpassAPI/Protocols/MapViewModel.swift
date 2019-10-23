//
//  MapViewModel.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// An API that provides information required to define a basic mapView's setup/behavior
protocol MapViewModel: NSObject {
	
	var region: MKCoordinateRegion? { get }
	var annotations: [MKAnnotation] { get }
	var overlays: [MKOverlay] { get }
	
	var setRegion: ((MKCoordinateRegion) -> Void)? { get set }
	var addAnnotations: (([MKAnnotation]) -> Void)? { get set }
	var addOverlays: (([MKOverlay]) -> Void)? { get set }
	var removeAnnotations: (([MKAnnotation]) -> Void)? { get set }
	var removeOverlays: (([MKOverlay]) -> Void)? { get set }
	
	func registerAnnotationViews(to mapView: MKMapView)
	func renderer(for overlay: MKOverlay) -> MKOverlayRenderer
	func view(for annotation: MKAnnotation) -> MKAnnotationView?
	func userDidGestureOnMapView(sender: UIGestureRecognizer)
}
