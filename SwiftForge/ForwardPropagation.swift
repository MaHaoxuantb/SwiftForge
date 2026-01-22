//
//  forward.swift
//  SwiftForge
//
//  Created by Thomas B on 1/12/26.
//

import Foundation
import MLX

func Prepare() async -> [MaterialCombination] {
    var filaments: [Material] = []
    
    filaments.append(Material(name: "PLA White", color: "White", brand: "Generic", RefractR: 0.9, RefractG: 0.9, RefractB: 0.9, absorbR: 0.1, absorbG: 0.1, absorbB: 0.1))
    filaments.append(Material(name: "PLA Black", color: "Black", brand: "Generic", RefractR: 0.1, RefractG: 0.1, RefractB: 0.1, absorbR: 0.9, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Red", color: "Red", brand: "Generic", RefractR: 0.8, RefractG: 0.1, RefractB: 0.1, absorbR: 0.1, absorbG: 0.9, absorbB: 0.9))
    filaments.append(Material(name: "PLA Green", color: "Green", brand: "Generic", RefractR: 0.1, RefractG: 0.8, RefractB: 0.1, absorbR: 0.8, absorbG: 0.2, absorbB: 0.8))
    filaments.append(Material(name: "PLA Blue", color: "Blue", brand: "Generic", RefractR: 0.1, RefractG: 0.1, RefractB: 0.8, absorbR: 0.9, absorbG: 0.9, absorbB: 0.2))
    filaments.append(Material(name: "AIR", color: "Transparent", brand: "Generic", RefractR: 0.1, RefractG: 0.1, RefractB: 0.1, absorbR: 0.1, absorbG: 0.1, absorbB: 0.1))
    
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
//                                print("pop: ", filament1.name, filament2.name, filament3.name, filament4.name, filament5.name, filament6.name)
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

//MARK: -Simulation
class Simulation {
    //MARK: Calculations
    func CalculateAbsorbtionPassed(I0: f64, Absorbance: f64) async -> f64 {
        // Beer–Lambert law: I = I0 * e^(−alpha * length)
        // Use Foundation's expf for f64 and a 1mm unit length (0.1 cm or appropriate units as intended)
        let length: f64 = 0.1
        let I1: f64 = I0 * exp(-Absorbance * length)
        return I1
    }
    
    func CalculateRefraction(I0: f64, refractanceBefore: f64, refractanceAfter: f64) async -> f64 {
        // Simple Refraction model: refracted intensity = I0 * refractance
        let R1: f64 = I0 * pow(((refractanceBefore - refractanceAfter)/(refractanceBefore + refractanceAfter)), 2)
        return R1
    }
    
    //MARK: One Step
    func SimulateOneStep(status: [(f64, f64, f64, f64)], MaterialStatus: [(f64, f64)]) async -> [(f64, f64, f64, f64)] {
        var status_calculated: [(f64, f64, f64, f64)] = status
        for boundary: Int in 0..<7 { // 0 -> 6 material(6)
            // 0
            if status_calculated[boundary].0 != f64(0.0) {
                var refracted: f64 = f64(0.0)
                let I0: f64 = status_calculated[boundary].0
                if (boundary) == 6 {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: MaterialStatus[boundary - 1].1, refractanceAfter: f64(0.5)) // DEBUG ONLY
                } else if boundary == 0 {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: f64(0.5), refractanceAfter: MaterialStatus[boundary].1) // DEBUG ONLY
                } else {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: MaterialStatus[boundary - 1].1, refractanceAfter: MaterialStatus[boundary].1)
                }
                status_calculated[boundary].1 += (I0 - refracted)
                status_calculated[boundary].3 += refracted
                status_calculated[boundary].0 = f64(0.0)
            }
            // 1
            if status_calculated[boundary].1 != f64(0.0) {
                if boundary != 6 {
                    let passed_amount = await CalculateAbsorbtionPassed(I0: status_calculated[boundary].1, Absorbance: MaterialStatus[boundary].0)
                    status_calculated[boundary + 1].0 += passed_amount
                    status_calculated[boundary].1 = f64(0.0)
                }
            }
            // 2
            if status_calculated[boundary].2 != f64(0.0) {
                var refracted: f64 = f64(0.0)
                let I0 : f64 = status_calculated[boundary].2
                if boundary == 0 {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: MaterialStatus[boundary].1, refractanceAfter: f64(0.5)) // DEBUG ONLY
                } else if boundary == 6 {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: f64(0.5), refractanceAfter: MaterialStatus[boundary - 1].1)  // DEBUG ONLY
                } else {
                    refracted = await CalculateRefraction(I0: I0, refractanceBefore: MaterialStatus[boundary].1, refractanceAfter: MaterialStatus[boundary - 1].1)
                }
                status_calculated[boundary].1 += refracted
                status_calculated[boundary].3 += (I0 - refracted)
                status_calculated[boundary].2 = f64(0.0)
            }
            //3
            if status_calculated[boundary].3 != f64(0.0) {
                if boundary != 0 {
                    let passed_amount = await CalculateAbsorbtionPassed(I0: status_calculated[boundary].3, Absorbance: MaterialStatus[boundary - 1].0)
                    status_calculated[boundary - 1].2 += passed_amount
                    status_calculated[boundary].3 = f64(0.0)
                }
            }
        }
        return status_calculated
    }
    
    //MARK: Prepare
    func ExtractMaterial(MaterialCombination: MaterialCombination) async -> ([(f64, f64)], [(f64, f64)], [(f64, f64)]) {
        var MaterialStatusR: [(f64, f64)] = []
        for material in MaterialCombination.materials {
            MaterialStatusR.append((material.absorbR, material.RefractR))
        }
        var MaterialStatusG: [(f64, f64)] = []
        for material in MaterialCombination.materials {
            MaterialStatusG.append((material.absorbG, material.RefractG))
        }
        var MaterialStatusB: [(f64, f64)] = []
        for material in MaterialCombination.materials {
            MaterialStatusB.append((material.absorbB, material.RefractB))
        }
        return (MaterialStatusR, MaterialStatusG, MaterialStatusB)
    }
    
    // Helper to create a default status array with initial incoming intensity at boundary 0
    private func makeDefaultStatus() -> [(f64, f64, f64, f64)] {
        var status = Array<(f64, f64, f64, f64)>(repeating: (f64(0), f64(0), f64(0), f64(0)), count: 7)
        status[0] = (f64(1), f64(0), f64(0), f64(0))
        return status
    }
    
    //MARK: MAIN
    public func Simulate(MaterialCombination: MaterialCombination) async -> RGBStatus {
        let (MaterialStatusR, MaterialStatusG, MaterialStatusB) = await ExtractMaterial(MaterialCombination: MaterialCombination)
        
        var statusR = makeDefaultStatus()
        var statusG = makeDefaultStatus()
        var statusB = makeDefaultStatus()
        
        for counter in 0..<1000 {
            statusR = await SimulateOneStep(status: statusR, MaterialStatus: MaterialStatusR)
            statusG = await SimulateOneStep(status: statusG, MaterialStatus: MaterialStatusG)
            statusB = await SimulateOneStep(status: statusB, MaterialStatus: MaterialStatusB)
            if counter == 0 {
                statusR[0].0 = f64(0.0)
                statusG[0].0 = f64(0.0)
                statusB[0].0 = f64(0.0)
            }
//            if statusR[6].1 < 0.0000000000000001 && statusG[6].1 < 0.0000000000000001 && statusB[6].1 < 0.0000000000000001 {
//                print("abcdefg")
//            } else {
//                print(statusR[6].1, statusG[6].1, statusB[6].1)
//            }
        }
        
        return RGBStatus(statusR: statusR, statusG: statusG, statusB: statusB)
    }
}
