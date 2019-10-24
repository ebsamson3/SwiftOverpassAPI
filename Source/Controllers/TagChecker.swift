//
//  TagChecker.swift
//  SwiftOverpassAPI
//
//  Created by Edward Samson on 10/5/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

// Checks whether an element contains tags that aren't included in the uninteresting tags set
struct TagChecker {
	
	static let uninterestingTags: Set<String> = [
        "source",
        "source_ref",
        "source:ref",
        "history",
        "attribution",
        "created_by",
        "tiger:county",
        "tiger:tlid",
        "tiger:upload_uuid"
	]

	static func checkForInterestingTags(amongstTags tags: [String: String]) -> Bool {
		for key in tags.keys {
			if !uninterestingTags.contains(key) {
				return true
			}
		}
		return false
	}	
}
