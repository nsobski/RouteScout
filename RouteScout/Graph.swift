//
//  Graph.swift
//  RouteScout
//
//  Created by Nicole Sobski on 5/21/25.
//

import Foundation
import CoreLocation

struct GraphNode {
    let id: Int
    let coordinate: CLLocationCoordinate2D
    var neighbors: [GraphEdge] = []
}

struct GraphEdge {
    let to: Int // destination node ID
    let cost: Double // distance in meters
}

extension GraphNode: Hashable {
    static func == (lhs: GraphNode, rhs: GraphNode) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

func haversineDistance(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Double {
    let locationA = CLLocation(latitude: a.latitude, longitude: a.longitude)
    let locationB = CLLocation(latitude: b.latitude, longitude: b.longitude)
    return locationA.distance(from: locationB) // measured in meters
}

func findNearestNode(to location: CLLocationCoordinate2D, in graph: [Int: GraphNode]) -> GraphNode? {
    return graph.values.min(by: {
        haversineDistance($0.coordinate, location) < haversineDistance($1.coordinate, location)
    })
}

func buildGraph(from ways: [OSMWay]) -> [Int: GraphNode] {
    var nodeIDCounter = 0
    var coordinateToID: [String: Int] = [:] // maps lat, lon to node ID
    var graph: [Int: GraphNode] = [:]
    
    func getOrCreateNodeID(for coordinate: OSMCoordinate) -> Int {
        let key = "\(coordinate.lat),\(coordinate.lon)"
        if let existingID = coordinateToID[key] {
            return existingID
        } else {
            let id = nodeIDCounter
            nodeIDCounter += 1
            coordinateToID[key] = id
            let coordinate = CLLocationCoordinate2D(latitude: coordinate.lat, longitude: coordinate.lon)
            graph[id] = GraphNode(id: id, coordinate: coordinate)
            return id
        }
    }
    
    for way in ways {
        let points = way.geometry
        for i in 0..<points.count - 1 {
            let idA = getOrCreateNodeID(for: points[i])
            let idB = getOrCreateNodeID(for: points[i + 1])
            
            let coordinateA = graph[idA]!.coordinate
            let coordinateB = graph[idB]!.coordinate
            let distance = haversineDistance(coordinateA, coordinateB)
            
            graph[idA]!.neighbors.append(GraphEdge(to: idB, cost: distance))
            graph[idB]!.neighbors.append(GraphEdge(to: idA, cost: distance))
        }
    }
    
    return graph
}
