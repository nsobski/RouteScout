//
//  PreferenceForm.swift
//  RouteScout
//
//  Created by Nicole Sobski on 5/18/25.
//

import SwiftUI

struct PreferenceForm: View {
    @Binding var mileage: Double
    @Binding var preferTrails: Bool
    @Binding var showAmenities: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Route Preferences")) {
                Stepper(value: $mileage, in: 0.5...20, step: 0.5) {
                    Text("Mileage: \(mileage, specifier: "%.1f") mi")
                }
                Toggle("Prefer Trails", isOn: $preferTrails)
                Toggle("Show Amenities", isOn: $showAmenities)
            }
        }
    }
}
