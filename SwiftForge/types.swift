//
//  types.swift
//  SwiftForge
//
//  Created by Thomas B on 1/15/26.
//

import Foundation

typealias f32 = Float32
typealias f64 = Float64

// Encapsulates the three channel status arrays
final class RGBStatus: CustomStringConvertible {
    var statusR: [(f64, f64, f64, f64)]
    var statusG: [(f64, f64, f64, f64)]
    var statusB: [(f64, f64, f64, f64)]

    init(statusR: [(f64, f64, f64, f64)], statusG: [(f64, f64, f64, f64)], statusB: [(f64, f64, f64, f64)]) {
        self.statusR = statusR
        self.statusG = statusG
        self.statusB = statusB
    }

    var description: String {
        "RGBStatus(R6: \(statusR[6].1), G6: \(statusG[6].1), B6: \(statusB[6].1))"
    }
}

// Define a material type with Swift-native types
class Material: CustomStringConvertible {
    var id: UUID
    var name: String
    var color: String
    var brand: String

    var RefractR: f64
    var RefractG: f64
    var RefractB: f64

    var absorbR: f64
    var absorbG: f64
    var absorbB: f64

    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        brand: String,
        RefractR: f64,
        RefractG: f64,
        RefractB: f64,
        absorbR: f64,
        absorbG: f64,
        absorbB: f64,
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.brand = brand

        self.RefractR = RefractR
        self.RefractG = RefractG
        self.RefractB = RefractB

        self.absorbR = absorbR
        self.absorbG = absorbG
        self.absorbB = absorbB
    }
    
    var description: String {
        "Material(name: \(name), color: \(color), brand: \(brand), Refract: [\(RefractR), \(RefractG), \(RefractB)], absorb: [\(absorbR), \(absorbG), \(absorbB)])"
    }
}


class MaterialCombination: CustomStringConvertible {
    var filament1: Material
    var filament2: Material
    var filament3: Material
    var filament4: Material
    var filament5: Material
    var filament6: Material
    init(filament1: Material, filament2: Material, filament3: Material, filament4: Material, filament5: Material, filament6: Material) {
        self.filament1 = filament1
        self.filament2 = filament2
        self.filament3 = filament3
        self.filament4 = filament4
        self.filament5 = filament5
        self.filament6 = filament6
    }
    
    var materials: [Material] {
        [filament1, filament2, filament3, filament4, filament5, filament6]
    }
    
    var description: String {
        let names = materials.map { $0.name }.joined(separator: ", ")
        return "MaterialCombination([\(names)])"
    }
}
