//
//  DecoderExtractor.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

// A dummy class used to extract decoders that are typically only accessable in init functions. 
struct DecoderExtractor: Decodable {
	
	let decoder: Decoder
	
	init(from decoder: Decoder) throws {
		self.decoder = decoder
	}
}
