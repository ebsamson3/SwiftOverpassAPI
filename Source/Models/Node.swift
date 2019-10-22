//
//  Node.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/2/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// A single geographic point. Can be a single point of interest or part of a group of nodes that form higher order objects like ways or relations.
struct Node: Element {
	
	let id: Int
	let tags: [String: String]
	let isInteresting: Bool // Node contains an interesting tag it's description
	var isSkippable: Bool // Node is already rendered by a parent way or relation
	let geometry: ElementGeometry // For nodes this will always be a single coordinate
}
