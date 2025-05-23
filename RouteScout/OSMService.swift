//
//  OSMService.swift
//  RouteScout
//
//  Created by Nicole Sobski on 5/20/25.
//

import Foundation
import CoreLocation

// OSM Models
struct OSMResponse: Codable {
    let elements: [OSMWay]
}

struct OSMWay: Codable {
    let id: Int
    let type: String
    let geometry: [OSMCoordinate]
}

struct OSMCoordinate: Codable {
    let lat: Double
    let lon: Double
}

// Network Function

func fetchWalkablePaths(
    lat: Double,
    lon: Double,
    completion: @escaping (Result<[OSMWay], Error>) -> Void
) {
    let query = """
    [out:json];
    (
        way["highway"~"footway|path|residential"]["foot"!~"no"](around:1500,\(lat),\(lon));
    );
    out geom;
    """
    
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let urlString = "https://overpass-api.de/api/interpreter?data=\(encodedQuery)"
    
    guard let url = URL(string: urlString) else {
        completion(.failure(NSError(domain: "Invalid URL", code: -1)))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data", code: -2)))
            return
        }
        
        do {
            let result = try JSONDecoder().decode(OSMResponse.self, from: data)
            completion(.success(result.elements.filter { $0.type == "way" }))
        } catch {
            completion(.failure(error))
        }
    }.resume()
}
