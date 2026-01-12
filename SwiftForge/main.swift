//
//  main.swift
//  SwiftForge
//
//  Created by Thomas B on 1/12/26.
//

import Foundation
import MLX

// Define a material type with Swift-native types
class Material {
    var id: UUID
    var name: String
    var color: String
    var brand: String

    var reflectR: Float
    var reflectG: Float
    var reflectB: Float

    var absorbR: Float
    var absorbG: Float
    var absorbB: Float

    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        brand: String,
        reflectR: Float,
        reflectG: Float,
        reflectB: Float,
        absorbR: Float,
        absorbG: Float,
        absorbB: Float
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.brand = brand

        self.reflectR = reflectR
        self.reflectG = reflectG
        self.reflectB = reflectB

        self.absorbR = absorbR
        self.absorbG = absorbG
        self.absorbB = absorbB
    }
}

var filaments: [Material] = []

filaments.append(Material(name: "PLA White", color: "White", brand: "Generic", reflectR: 0.9, reflectG: 0.9, reflectB: 0.9, absorbR: 0.1, absorbG: 0.1, absorbB: 0.1))
filaments.append(Material(name: "PLA Black", color: "Black", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.1, absorbR: 0.9, absorbG: 0.9, absorbB: 0.9))
filaments.append(Material(name: "PLA Red", color: "Red", brand: "Generic", reflectR: 0.8, reflectG: 0.1, reflectB: 0.1, absorbR: 0.2, absorbG: 0.9, absorbB: 0.9))
filaments.append(Material(name: "PLA Green", color: "Green", brand: "Generic", reflectR: 0.1, reflectG: 0.8, reflectB: 0.1, absorbR: 0.9, absorbG: 0.2, absorbB: 0.9))
filaments.append(Material(name: "PLA Blue", color: "Blue", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.8, absorbR: 0.9, absorbG: 0.9, absorbB: 0.2))

// Placeholder for combined color results
var allColorCombine: [String] = []

// i1 = 255 * (1 - Reflectance)^2 * e^(-absorbance * distance)
// Example nested iteration over combinations (no-op body for now)
for filament1 in filaments {
    for filament2 in filaments {
        for filament3 in filaments {
            for filament4 in filaments {
                for filament5 in filaments {
                    // Do combination work here if needed
                    let combo = [filament1.id, filament2.id, filament3.id, filament4.id, filament5.id]
                        .map { $0.uuidString }
                        .joined(separator: ",")
                    allColorCombine.append(combo)
                }
            }
        }
    }
}
// Prevent the program from exiting immediately if needed
print("Loaded \(filaments.count) materials.")

