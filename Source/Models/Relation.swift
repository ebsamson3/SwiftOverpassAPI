//
//  Relation.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/2/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// A collection of related overpass members. Members can be nodes, ways (paths made up of nodes), and other relations.
struct Relation: Element {

	struct Member {
		
		let type: ElementType // The member's type
		let id: Int // The member's unique identifier
		let role: String // The role a member playes in the relation
		let coordinates: [CLLocationCoordinate2D] // The coordinates of the member
		
		// Used to decode the member from an Overpass API JSON response.
		enum CodingKeys: String, CodingKey {
			case type, role, geometry, nodes
			case id = "ref"
		}
	}
	
	let id: Int
	let tags: [String: String]
	let isInteresting: Bool // Relatin contains an interesting descriptive tag
	var isSkippable: Bool // Relation is already rendered by a parent element
	let members: [Int] // Members that form the relation
	let geometry: ElementGeometry // The relation's geometry type
}

extension Relation {
	// Many relations are just collections of related objects, but these relation types require specific renderings
	static let displayableTypes: Set<String> = [
		Overpass.Values.multipolygon,
		Overpass.Values.barrier,
		Overpass.Values.route,
		Overpass.Values.waterway
	]
}
