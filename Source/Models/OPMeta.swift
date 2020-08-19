//
//  OPMeta.swift
//  SwiftOverpassAPI
//
//  Created by Wolfgang Timme on 4/6/20.
//  Copyright © 2020 Edward Samson. All rights reserved.
//

import Foundation

/// Meta information about elements
public struct OPMeta {
    /// OSM object's version number
    public let version: Int
    
    /// Last changed timestamp of an OSM object
    public let timestamp: String
    
    /// Changeset in which the object was changed
    public let changeset: Int
    
    /// OSM User id
    public let userId: Int
    
    /// OSM User name
    public let username: String
}
