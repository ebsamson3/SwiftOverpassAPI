//
//  Errors.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/6/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

// Errors that can result from Overpass requests
public enum OPRequestError: LocalizedError {
	case badResponse(HTTPURLResponse)
	case nilData
	case decodingFailed
	case queryCancelled
	
	public var errorDescription: String? {
		switch self {
		case .badResponse(let response):
			return "Bad HTTP response: \(response)"
		case .nilData:
			return "Query response returned nil data"
		case .decodingFailed:
			return "Query response data could not be decoded"
		case .queryCancelled:
			return "Query cancelled by user"
		}
	}
}

// Erros that can result from decoding overpass elements
public enum OPElementDecoderError: LocalizedError {
	case invalidWayLength(wayId: Int)
	case unexpectedNil(elementId: Int)
	case emptyRelation
	
	public var errorDescription: String? {
		switch self {
		case .invalidWayLength(let id):
			return "Unable to construct the full geometry for way with id: \(id)"
		case .unexpectedNil(let elementId):
			return "Unexpected nil when decoding element with id: \(elementId)"
		case .emptyRelation:
			return "Unable to create geometry for relation with 0 valid members"
			
		}
	}
}

// Errors that can result from attempting to build invalid Overpass API queries
public enum OPQueryBuilderError: LocalizedError {
	case noElementTypesSpecified
	
	public var errorDescription: String? {
		switch self {
		case .noElementTypesSpecified:
			return "Queries must contain at least one element type"
		}
	}
}

