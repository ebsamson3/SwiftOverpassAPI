//
//  MapViewController.swift
//  OverpassDemo
//
//  Created by Edward Samson on 10/10/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
	
	lazy var center = mapView.region.center
	private var edgeInsets: UIEdgeInsets?
	
	lazy var mapView: MKMapView = {
		let mapView = MKMapView()
		mapView.delegate = self
		return mapView
	}()
	
	private var regionIsChanging = false
	private var pendingMovement: DispatchWorkItem?
	
	let viewModel: MapViewModel
	
	init(viewModel: MapViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		
		let panGesureRecognizer = UIPanGestureRecognizer.init(
			target: self,
			action: #selector(userDidGestureOnMapView(sender:)))
		
		panGesureRecognizer.delegate = self
		
		let pinchGestureRecognizer = UIPinchGestureRecognizer.init(
			target: self,
			action: #selector(userDidGestureOnMapView(sender:)))
		
		pinchGestureRecognizer.delegate = self
		
		let rotationGestureRecognizer = UIRotationGestureRecognizer.init(
			target: self,
			action: #selector(userDidGestureOnMapView(sender:)))
		
		rotationGestureRecognizer.delegate = self
		
		mapView.addGestureRecognizer(panGesureRecognizer)
		mapView.addGestureRecognizer(pinchGestureRecognizer)
		mapView.addGestureRecognizer(rotationGestureRecognizer)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.registerAnnotationViews(to: mapView)
		
		viewModel.setRegion = { [weak self] region in
			self?.updateRegion(to: region)
		}
		
		viewModel.addAnnotations = { [weak self] annotations in
			self?.mapView.addAnnotations(annotations)
		}
		
		viewModel.addOverlays = { [weak self] overlays in
			self?.mapView.addOverlays(overlays)
		}
		
		viewModel.removeAnnotations = { [weak self] annotations in
			self?.mapView.removeAnnotations(annotations)
		}
		
		viewModel.removeOverlays = { [weak self] overlays in
			self?.mapView.removeOverlays(overlays)
		}
		
		if let region = viewModel.region {
			mapView.setRegion(region, animated: true)
		}
		
		mapView.addAnnotations(viewModel.annotations)
		mapView.addOverlays(viewModel.overlays)
		
		configure()
	}

	private func configure() {
		view.addSubview(mapView)
		mapView.translatesAutoresizingMaskIntoConstraints = false
		mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
		mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
		mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
	}
	
	func setEdgeInsets(to edgeInsets: UIEdgeInsets) {
		self.edgeInsets = edgeInsets
		
		guard let region = viewModel.region else {
			return
		}
		
		updateRegion(to: region)
	}
	
	private func updateRegion(to region: MKCoordinateRegion) {
		
		guard let edgeInsets = edgeInsets else {
			mapView.setRegion(region, animated: true)
			return
		}
		
		let rect = mapRect(region: region)
		
		mapView.setVisibleMapRect(
			rect,
			edgePadding: edgeInsets,
			animated: true)
	}
	
	func mapRect(region: MKCoordinateRegion) -> MKMapRect {
		let topLeft = CLLocationCoordinate2D(
			latitude: region.center.latitude + (region.span.latitudeDelta/2.0),
			longitude: region.center.longitude - (region.span.longitudeDelta/2.0)
		)
		
		let bottomRight = CLLocationCoordinate2D(
			latitude: region.center.latitude - (region.span.latitudeDelta/2.0),
			longitude: region.center.longitude + (region.span.longitudeDelta/2.0)
		)
		
		let topLeftMapPoint = MKMapPoint(topLeft)
		let bottomRightMapPoint = MKMapPoint(bottomRight)
		
		let origin = MKMapPoint(
			x: topLeftMapPoint.x,
			y: topLeftMapPoint.y)
		
		let size = MKMapSize(
			width: fabs(bottomRightMapPoint.x - topLeftMapPoint.x),
			height: fabs(bottomRightMapPoint.y - topLeftMapPoint.y))
		
		return MKMapRect(origin: origin, size: size)
	}
	
	@objc func userDidGestureOnMapView(sender: UIGestureRecognizer) {
		viewModel.userDidGestureOnMapView(sender: sender)
	}
}

extension MapViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
		return viewModel.renderer(for: overlay)
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		return viewModel.view(for: annotation)
	}
	
	func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
		regionIsChanging = true
	}
	
	func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
		regionIsChanging = false
		pendingMovement?.perform()
	}
}

extension MapViewController: UIGestureRecognizerDelegate {
	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer,
		shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
	{
		return true
	}
}
