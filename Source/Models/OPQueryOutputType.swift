//
//  OPQueryOutputType.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
/*
	Output types that effect the structure of JSON data returned by an Overpass API request.

	Standard: Returned elements contain refrence ids to their child elements.

	Recurse down: Standard output but query will return child objects for any parent element returned in the initial query. For example, querying a relation will also return any ways and/or nodes that are members in that relation.

	Recurse up: Standard output but query will return parent objects for any child element returned in the initial query. Fore example, querying for a node will also return any ways and/or relations that the node is a member of.

	Recurse up and down: Recurse up, then recurse down on the result of the upwards recursion.

	Geometry: Each returned element will contain a list of coorindates that define it's geometry.

	Center: Each returned element will contain it's center point. Use this if you are only concerned with representing the element as a single point or marker on a map.
*/
public enum OPQueryOutputType {
	case standard, center, geometry, recurseDown, recurseUp, recurseUpAndDown
	
	// The Overpass API language syntax for each output type
	func toString() -> String {
		switch self {
		case .standard:
			return "out;"
		case .recurseDown:
			return "(._;>;);out;"
		case .recurseUp:
			return "(._;<;);out;"
		case .recurseUpAndDown:
			return "((._;<;);>;);out;"
		case .geometry:
			return "out geom;"
		case .center:
			return "out center;"
		}
	}
}
