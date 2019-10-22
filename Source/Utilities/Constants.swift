//
//  Constants.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/19/19.
//

import Foundation

// Constants for Keys and Values that can potentially arise in Overpass API JSON response data.
struct Overpass {
	
	struct Keys {
		static let name = "name"
		static let area = "area"
		static let type = "type"
		static let latitude = "lat"
		static let longitude = "lon"
	}
	
	struct Values {
		static let no = "no"
		static let outer = "outer"
		static let inner = "inner"
		static let multipolygon = "multipolygon"
		static let barrier = "barrier"
		static let route = "route"
		static let waterway = "waterway"
	}
}
