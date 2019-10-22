//
//  Way.swift
//  OverpassApiVisualizer
//
//  Created by Edward Samson on 10/2/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import MapKit

// A collection of nodes that form a polylinear or polygonal geographic feature. Common examples include road ands buildings.
public struct Way: Element{
	public let id: Int
	public let tags: [String: String]
	public let isInteresting: Bool // Way has interesting tags in it's description
	public var isSkippable: Bool // Way is already rendered by a parent relation
	public let nodes: [Int]  // Nodes for each coordinate in a way's geometry
	public let geometry: ElementGeometry // For a way this will be either a polyline or a polygon
}
