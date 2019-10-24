//
//  PolygonChecker.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/6/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import CoreLocation

// Checks whether or not a way (an array of lat/lon pairs) returned by the overpass API forms a polygon or not
struct PolygonChecker {
	
	// Keys that are valid for polygons EXCEPT when they have the following associated values
	private static let blacklist : [String: Set<String>] = [
		"area:highway": ["no"],
		"aeroway": ["no", "taxiway"],
		"amenity": ["no"],
		"boundary": ["no"],
		"building:part": ["no"],
		"building": ["no"],
		"craft": ["no"],
		"golf": ["no"],
		"historic": ["no"],
		"indoor": ["no"],
		"landuse": ["no"],
		"leisure": ["no", "cutline", "embankment", "pipeline"],
		"natural": ["no", "coastline", "cliff", "ridge", "arete", "tree_row"],
		"office": ["no"],
		"place": ["no"],
		"public_transport": ["no"],
		"ruins": ["no"],
		"shop": ["no"],
		"tourism": ["no"]
	]
	
	// Keys that are valid for polygons whenever the have the following associated values
	private static let whitelist : [String: Set<String>] = [
		"barrier": ["city_wall", "ditch", "hedge", "retaining_wall", "wall, spikes"],
		"highway": ["services", "rest_area", "escape", "elevator"],
		"power": ["plant", "substation", "generator", "transformer"],
		"railway": ["station", "turntable", "roundhouse", "platform"],
		"waterway": ["riverbank", "dock", "boatyard", "dam"]
	]
	
	// Checks to see whether the tags/geometry are valid for a polygon
	static func checkWay(
		withCoordinates coordinates: [CLLocationCoordinate2D],
		andTags tags: [String: String]) -> Bool
	{
		return check(coordinates: coordinates) && check(tags: tags)
	}
	
	// Check for tags that are always included/never included in polygons
	private static func check(tags: [String: String]) -> Bool {
		
		// If the way has an "area" tag that isn't set to "no"
		if let areaValue = tags[Overpass.Keys.area] {
			return areaValue == Overpass.Values.no ? false : true
		}
		
		for (key, value) in tags {
			
			// If the key is valid and the value isn't on the blacklist (See blacklist for more details)
			if
				let blacklistedValues = blacklist[key],
				!blacklistedValues.contains(value)
			{
				return true
			}
			
			// Checks to see if the tag matches any whitelisted key/value pairs (See whitelist for more details)
			if
				let whitelistedValues = whitelist[key],
				whitelistedValues.contains(value)
			{
				return true
			}
		}
		
		// If no tags specify that the way is a polygon, return false
		return false
	}
	
	//Check to make sure that there are at least 4 coordinates and that the first and last coordinates are the same. If both are true than the way geometry is valid for a polygon.
	private static func check(coordinates: [CLLocationCoordinate2D]) -> Bool {
		if
			coordinates.count > 3,
			let firstCoordinate = coordinates.first,
			let lastCoordinate = coordinates.last,
			firstCoordinate.isEqual(to: lastCoordinate)
		{
			return true
		}
		
		return false
	}
}
