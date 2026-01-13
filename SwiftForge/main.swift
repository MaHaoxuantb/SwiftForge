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

class ColorCombination {
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
}

func Prepare() async -> [ColorCombination] {
    var filaments: [Material] = []
    
    filaments.append(Material(name: "PLA White", color: "White", brand: "Generic", reflectR: 0.9, reflectG: 0.9, reflectB: 0.9, absorbR: 0.1, absorbG: 0.1, absorbB: 0.1))
    filaments.append(Material(name: "PLA Black", color: "Black", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.1, absorbR: 0.9, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Red", color: "Red", brand: "Generic", reflectR: 0.8, reflectG: 0.1, reflectB: 0.1, absorbR: 0.2, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Green", color: "Green", brand: "Generic", reflectR: 0.1, reflectG: 0.8, reflectB: 0.1, absorbR: 0.9, absorbG: 0.2, absorbB: 0.9))
    filaments.append(Material(name: "PLA Blue", color: "Blue", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.8, absorbR: 0.9, absorbG: 0.9, absorbB: 0.2))
    filaments.append(Material(name: "AIR", color: "Transparent", brand: "Generic", reflectR: 0, reflectG: 0, reflectB: 0, absorbR: 0, absorbG: 0, absorbB: 0))
    
    // Placeholder for combined color results
    print("Start Material")
    
    var allColorCombine: [ColorCombination] = []
    
    for filament1 in filaments {
        for filament2 in filaments {
            for filament3 in filaments {
                for filament4 in filaments {
                    for filament5 in filaments {
                        for filament6 in filaments {
                            // Do combination work here if needed
                            if (filament2.name == "AIR" && filament3.name != "AIR") || (filament3.name == "AIR" && filament4.name != "AIR") || (filament4.name == "AIR" && filament5.name != "AIR") || (filament5.name == "AIR" && filament6.name != "AIR") {
                                print("push: ", filament1.name, filament2.name, filament3.name, filament4.name, filament5.name, filament6.name)
                                continue
                            } else {
                                allColorCombine.append(ColorCombination(filament1: filament1, filament2: filament2, filament3: filament3, filament4: filament4, filament5: filament5, filament6: filament6))
                            }
                        }
                    }
                }
            }
        }
    }
    print("Loaded \(filaments.count) materials.")
    return allColorCombine
}


let allColorCombine: [ColorCombination] = await Prepare()



