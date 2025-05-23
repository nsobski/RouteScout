//
//  ContentView.swift
//  RouteScout
//
//  Created by Nicole Sobski on 5/18/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 42.29307, longitude: -71.30837), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    @State private var mileage: Double = 3.0
    @State private var preferTrails: Bool = false
    @State private var showAmenities: Bool = false
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    
    var body: some View {
        VStack {
            if let location = locationManager.location {
                MapView(region: $region, route: routeCoordinates)
                    .onAppear {
                        region.center = location
                    }
                    .frame(height: 300)
            } else {
                Text("Fetching location...")
                    .padding()
            }
            PreferenceForm(mileage: $mileage,
                           preferTrails: $preferTrails,
                           showAmenities: $showAmenities)
            Button("Generate Route") {
                if let userLocation = locationManager.location {
                    fetchWalkablePaths(lat: userLocation.latitude, lon: userLocation.longitude) { result in
                        switch result {
                        case .success(let ways):
                            let graph = buildGraph(from: ways)
                            
                            if let start = findNearestNode(to: userLocation, in: graph) {
                                let meters = mileage * 1609.34
                                let route = walkRandomly(from: start, in: graph, maxDistance: meters)
                                
                                DispatchQueue.main.async {
                                    routeCoordinates = route
                                }
                            } else {
                                print("Could not find a start node near user")
                            }
                        
                        case .failure(let error):
                            print("Error fetching OSM data: \(error)")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    func generateMockRoute(from center: CLLocationCoordinate2D, mileage: Double) {
        let distanceInDegrees = (mileage / 69.0) / 4 // roughly convert miles to lat/long degrees
        
        let route = [
            CLLocationCoordinate2D(latitude: center.latitude + distanceInDegrees, longitude: center.longitude),
            CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude + distanceInDegrees),
            CLLocationCoordinate2D(latitude: center.latitude - distanceInDegrees, longitude: center.longitude),
            CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude - distanceInDegrees),
            CLLocationCoordinate2D(latitude: center.latitude + distanceInDegrees, longitude: center.longitude) // closing the loop
        ]
        
        routeCoordinates = route
    }
}

#Preview {
    ContentView()
}
