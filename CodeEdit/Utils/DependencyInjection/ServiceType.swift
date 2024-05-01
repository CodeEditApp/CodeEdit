//
//  ServiceType.swift
//  CodeEdit
//
//  Created by Abe Malla on 4/3/24.
//

/// Defines the type of service instantiation strategy.
enum ServiceType {
    /// Returns a new singleton on the first call, then returns a cached one every other time
    case singleton
    /// Creates a new singleton reference each time and caches it, returning the newer singleton
    case newSingleton
    /// Creates a new singleton
    case new
}
