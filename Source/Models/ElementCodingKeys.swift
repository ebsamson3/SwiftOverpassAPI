//
//  ElementCodingKeys.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/13/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

// Coding keys that may be found w/in a single element of an overpass API result
enum ElementCodingKeys: String, CodingKey {
	case id, type, tags, center, nodes, members, geometry, version, timestamp, changeset
	case latitude = "lat"
	case longitude = "lon"
    case userId = "uid"
    case username = "user"
}
