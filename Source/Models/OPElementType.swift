//
//  OPElementType.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

/*
	The types of elements that can be returned by an Overpass API request.
	Node: A single geographic point. Can be a single point of interest or part of a group of nodes that form higher order objects like ways or relations.
	Way: A collection of nodes that form a polylinear or polygonal geographic feature. Common examples include road ands buildings.
	Relation: A collection of related overpass members. Members can be nodes, ways (paths made up of nodes), and other relations.
*/
public enum OPElementType: String, Codable {
	case node = "node"
	case way = "way"
	case relation = "relation"
	
	// The Overpass API language syntax for each element type.
	public var shortString: String {
		switch self {
		case .node:
			return "node"
		case .way:
			return "way"
		case .relation:
			return "rel"
		}
	}
}
