//
//  ServiceTypes.swift
//  CodeEditV2
//
//  Created by Abe Malla on 3/20/24.
//

enum ServiceType {
    /// Returns a new singleton on the first call, then returns a cached one every other time
    case singleton
    /// Creates a new singleton reference each time and caches it, returning the newer singleton
    case newSingleton
    /// Creates a new singleton
    case new
}
