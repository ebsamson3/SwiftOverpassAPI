//
//  MKCoordinateRegion+Extensions.swift
//  SwiftOverpassAPI_Example
//
//  Created by Edward Samson on 10/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
	
	/*
		Converting a map regin to a map rect.
		Copy-Pasta'd from:
		https://stackoverflow.com/questions/9270268/convert-mkcoordinateregion-to-mkmaprect
	*/
	
	func toMKMapRect() -> MKMapRect {
		let topLeft = CLLocationCoordinate2D(
			latitude: self.center.latitude + (self.span.latitudeDelta/2.0),
			longitude: self.center.longitude - (self.span.longitudeDelta/2.0)
		)
		
		let bottomRight = CLLocationCoordinate2D(
			latitude: self.center.latitude - (self.span.latitudeDelta/2.0),
			longitude: self.center.longitude + (self.span.longitudeDelta/2.0)
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
}

