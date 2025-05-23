//
//  PathFinder.swift
//  RouteScout
//
//  Created by Nicole Sobski on 5/21/25.
//

import Foundation
import CoreLocation

func walkRandomly(from start: GraphNode, in graph: [Int: GraphNode], maxDistance: Double) -> [CLLocationCoordinate2D] {
    var path: [CLLocationCoordinate2D] = [start.coordinate]
    var totalDistance: Double = 0
    var current = start
    var visited: Set<Int> = [start.id]
    
    while totalDistance < maxDistance {
        guard let nextEdge = current.neighbors.shuffled().first(where: { !visited.contains($0.to) }),
              let nextNode = graph[nextEdge.to] else {
            break // dead end
        }
        
        totalDistance += nextEdge.cost
        path.append(nextNode.coordinate)
        visited.insert(nextNode.id)
        current = nextNode
    }
    
    return path
}
