//
//  OPQueryBuilder.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/11/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

/*:
	A convinience class for creating simple queries written in the Overpass API language.
	For more information, see the Overpass API Language Guide:
	https://wiki.openstreetmap.org/wiki/Overpass_API/Language_Guide
*/

import Foundation

public class OPQueryBuilder {
	
	// Overpass API results have a dictionary of descriptive tag/value pairs. The query builder uses the tag filter struct to filter based on these values.
	struct TagFilter {
		let key: String
		let value: String?
		let exactMatch: Bool // True: Filter passes any value that matches the Tag Filter value property, False: Filters passes any value that contains the tag filter value property (case insensitive).
		
		func toString() -> String {
			//If the value property of the Tag Filter is nil, Filter for any result that contains the Tag Filters key, regardless of the key's corresponding value.
			guard let value = value else {
				return "[\(key)]"
			}
			
			// exactMatchOnly == true: Filter passes any value that matches the Tag Filter value property. exactMatchOnly == false: Filters passes any value that contains the tag filter value property (case insensitive).
			return exactMatch ?
				"[\"\(key)\"=\"\(value)\"]" :
				"[\"\(key)\"~\"\(value)\",i]"
		}
	}
	
	private var tagFilters = [TagFilter]()
	private var boundingBox: OPBoundingBox?
	private var elementTypes = Set<OPElementType>()
	private var outputType: OPQueryOutputType = .standard
	private var timeOut: Int?
	private var maxSize: Int?
	
	public init() {}
	
	// Add a new filter that checks for the presence of a particular tag key or tag key/value pair in an Overpass element's descriptive data
	public func addTagFilter(
		key: String,
		value: String? = nil,
		exactMatch: Bool = true) -> Self
	{
		let tagFilter = TagFilter(
			key: key,
			value: value,
			exactMatch: exactMatch)
		
		tagFilters.append(tagFilter)
		
		return self
	}
	
	// Set search region for query. Defaults to a bounding box for the entire earch.
	public func setBoundingBox(_ boundingBox: OPBoundingBox) -> Self {
		
		self.boundingBox = boundingBox
		
		return self
	}
	
	// Set the element types the query can return. Possible types: Node, Way, and Relation
	public func setElementTypes(_ elementTypes: Set<OPElementType>) -> Self {
		self.elementTypes = elementTypes
		return self
	}
	
	//Sets teh output type of a query. Can return center. See OverpassQueryOutputType.swift
	public func setOutputType(_ outputType: OPQueryOutputType) -> Self {
		self.outputType = outputType
		return self
	}
	
	// Not sure if this works. The query will still run but it doesn't appear as if the timeout length was effected. It may be due to the endpoint I have used to test this API.
	public func setTimeOut(_ timeOut: Int) -> Self {
		self.timeOut = timeOut
		return self
	}
	
	// Set max size of results in bytes
	public func setMaxSize(_ maxSize: Int) -> Self {
		self.maxSize = maxSize
		return self
	}
	
	// Generate a string representation of the query in the Overpass API language.
	public func buildQueryString() throws -> String {
		
		let elementTypeCount = elementTypes.count
		
		// Query will throw if you do not set a least one returned element type.
		guard elementTypeCount > 0 else {
			throw OPQueryBuilderError.noElementTypesSpecified
		}
		
		// Header specifying a JSON response from the Overpass endpoint
		let dataOutputString = "data=[out:json]"
		
		// If querying multiple element types, the types need to be grouped by parenthesis.
		let elementGroupStart = elementTypeCount > 1 ? "(" : ""
		let elementGroupEnd = elementTypeCount > 1 ? ");" : ""
		
		// Generate Overpass language strings for the query's tag filters, bounding box, and JSON data output structure.
		let tagFilterString = tagFilters.map { $0.toString() }.joined()
		let boundingBoxString = boundingBox?.toString() ?? ""
		let outputTypeString = outputType.toString()
		
		let timeOutString: String
		
		// Add a paramter for the timout of the query if it exists
		if let timeOut = timeOut {
			timeOutString = "[timeout:\(timeOut)]"
		} else {
			timeOutString = ""
		}
		
		let maxSizeString: String
		
		// Add a paramater for the max size to the query if it exists
		if let maxSize = maxSize {
			maxSizeString = "[maxsize:\(maxSize)]"
		} else {
			maxSizeString = ""
		}
		
		// Combined query header containing the optional time out and max size parameters
		let headerString = dataOutputString + timeOutString + maxSizeString + ";"
		
		
		// For each expected element type, add all tag filters and specify the square search region (bounding box). Then join the commands for each element type into a single string to form the main body of the query.
		let queryBody: String = elementTypes.map { elementType in
			
			let elementTypeString = elementType.shortString
			
			let substring = String(
				format: "%@%@%@%@",
				elementTypeString,
				tagFilterString,
				boundingBoxString,
				";")
			
			return substring
			
		}.joined()
		
		// Combine the header, body, and output type query components to form the completed query.
		let queryString = String(
			format: "%@%@%@%@%@",
			headerString,
			elementGroupStart,
			queryBody,
			elementGroupEnd,
			outputTypeString)
		
		return queryString
	}
}


