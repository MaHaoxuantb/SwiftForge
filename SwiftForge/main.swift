//
//  main.swift
//  SwiftForge
//
//  Created by Thomas B on 1/12/26.
//

import Foundation
import MLX

typealias f32 = Float32
typealias f64 = Float64

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

class MaterialCombination {
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
}

func Prepare() async -> [MaterialCombination] {
    var filaments: [Material] = []
    
    filaments.append(Material(name: "PLA White", color: "White", brand: "Generic", reflectR: 0.9, reflectG: 0.9, reflectB: 0.9, absorbR: 0.1, absorbG: 0.1, absorbB: 0.1))
    filaments.append(Material(name: "PLA Black", color: "Black", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.1, absorbR: 0.9, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Red", color: "Red", brand: "Generic", reflectR: 0.8, reflectG: 0.1, reflectB: 0.1, absorbR: 0.2, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Green", color: "Green", brand: "Generic", reflectR: 0.1, reflectG: 0.8, reflectB: 0.1, absorbR: 0.9, absorbG: 0.2, absorbB: 0.9))
    filaments.append(Material(name: "PLA Blue", color: "Blue", brand: "Generic", reflectR: 0.1, reflectG: 0.1, reflectB: 0.8, absorbR: 0.9, absorbG: 0.9, absorbB: 0.2))
    filaments.append(Material(name: "AIR", color: "Transparent", brand: "Generic", reflectR: 0, reflectG: 0, reflectB: 0, absorbR: 0, absorbG: 0, absorbB: 0))
    
    // Placeholder for combined color results
    print("Start Material")
    
    var allMaterialCombine: [MaterialCombination] = []
    
    for filament1 in filaments {
        for filament2 in filaments {
            for filament3 in filaments {
                for filament4 in filaments {
                    for filament5 in filaments {
                        for filament6 in filaments {
                            // Do combination work here if needed
                            if (filament2.name == "AIR" && filament3.name != "AIR") || (filament3.name == "AIR" && filament4.name != "AIR") || (filament4.name == "AIR" && filament5.name != "AIR") || (filament5.name == "AIR" && filament6.name != "AIR") {
                                print("pop: ", filament1.name, filament2.name, filament3.name, filament4.name, filament5.name, filament6.name)
                                continue
                            } else {
                                allMaterialCombine.append(MaterialCombination(filament1: filament1, filament2: filament2, filament3: filament3, filament4: filament4, filament5: filament5, filament6: filament6))
                            }
                        }
                    }
                }
            }
        }
    }
    print("Loaded \(filaments.count) materials.")
    return allMaterialCombine
}


let allMaterialCombine: [MaterialCombination] = await Prepare()
print(allMaterialCombine.count)

//MARK: -Simulation
class Simulation {
    //MARK: Calculations
    func CalculateAbsorbtion(I0: f32, Absorbance: f32) async -> f32 {
        // Beer–Lambert law: I = I0 * e^(−alpha * length)
        // Use Foundation's expf for f32 and a 1mm unit length (0.1 cm or appropriate units as intended)
        let length: f32 = 0.1
        let I1: f32 = I0 * expf(-Absorbance * length)
        return I1
    }
    
    func CalculateReflection(I0: f32, ReflectanceBefore: f32, ReflectanceAfter: f32) async -> f32 {
        // Simple reflection model: reflected intensity = I0 * Reflectance
        let R1: f32 = I0 * ((ReflectanceBefore - ReflectanceAfter)/(ReflectanceBefore + ReflectanceAfter))
        return R1
    }
    
    //MARK: One Step
    func SimulateOneStep(status: [(f32, f32, f32, f32)], MaterialStatus: [(f32, f32)]) async -> [(f32, f32, f32, f32)] {
        var status_calculated: [(f32, f32, f32, f32)] = status
        for boundary in 0..<7 { // 0 -> 6 material(6)
            // 0
            if status_calculated[boundary].0 != f32(0.0) {
                let reflected = await CalculateReflection(I0: status[boundary].0, ReflectanceBefore: MaterialStatus[boundary].1, ReflectanceAfter: MaterialStatus[boundary + 1].1)
                status_calculated[boundary].1 = status_calculated[boundary].1 + (1 - reflected)
                status_calculated[boundary].3 = status_calculated[boundary].3 + reflected
            }
            // Get the source light out, for the first boundary
            if status_calculated[boundary].0 != f32(1.0) {
                status_calculated[boundary].0 = f32(0.0)
            }
            // 1
            if status_calculated[boundary].1 != f32(0.0) {
                if boundary != 6 {
                    let passed_amount = await CalculateAbsorbtion(I0: status_calculated[boundary].1, Absorbance: MaterialStatus[boundary].0)
                    status_calculated[boundary + 1].0 = status_calculated[boundary + 1].0 + passed_amount
                }
            }
            // 2
            if status_calculated[boundary].2 != f32(0.0) {
                var reflected: f32 = f32(0.0)
                if (boundary - 1) != 0 {
                    reflected = await CalculateReflection(I0: status_calculated[boundary].2, ReflectanceBefore: MaterialStatus[boundary].1, ReflectanceAfter: MaterialStatus[boundary - 1].1)
                } else {
                    reflected = await CalculateReflection(I0: status_calculated[boundary].2, ReflectanceBefore: MaterialStatus[boundary].1, ReflectanceAfter: f32(0.0))
                }
                status_calculated[boundary].1 = status_calculated[boundary].1 + reflected
                status_calculated[boundary].3 = status_calculated[boundary].3 + (1 - reflected)
            }
            //3
            if status_calculated[boundary].3 != f32(0.0) {
                if boundary != 0 {
                    let passed_amount = await CalculateAbsorbtion(I0: status_calculated[boundary].3, Absorbance: MaterialStatus[boundary].0)
                    status_calculated[boundary - 1].2 = status_calculated[boundary - 1].2 + passed_amount
                }
            }
        }
        return status_calculated
    }
    
    //MARK: Prepare
    func ExtractMaterial(MaterialCombination: MaterialCombination) async -> ([(f32, f32)], [(f32, f32)], [(f32, f32)]) {
        var MaterialStatusR: [(f32, f32)] = []
        for material in MaterialCombination.materials {
            MaterialStatusR.append((material.absorbR, material.reflectR))
        }
        var MaterialStatusG: [(f32, f32)] = []
        for material in MaterialCombination.materials {
            MaterialStatusG.append((material.absorbG, material.reflectG))
        }
        var MaterialStatusB: [(f32, f32)] = []
        for material in MaterialCombination.materials {
            MaterialStatusB.append((material.absorbB, material.reflectB))
        }
        return (MaterialStatusR, MaterialStatusG, MaterialStatusB)
    }
    
    //MARK: MAIN
    public func Simulate(MaterialCombination: MaterialCombination) async {
        var status: [(f32, f32, f32, f32)] = [
            (1.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32),
            (0.0 as f32, 0.0 as f32, 0.0 as f32, 0.0 as f32)
        ]
        let (MaterialStatusR, MaterialStatusG, MaterialStatusB) = await ExtractMaterial(MaterialCombination: MaterialCombination)
        
        status = await SimulateOneStep(status: status, MaterialStatus: MaterialStatusR)
    }
}

