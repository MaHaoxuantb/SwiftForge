//
//  main.swift
//  SwiftForge
//
//  Created by Thomas B on 1/22/26.
//

import Darwin

//let allMaterialCombine: [MaterialCombination] = await Prepare()
//print(allMaterialCombine.count)
//// Safely access an index only if it exists
//if allMaterialCombine.indices.contains(10000) {
//    print(allMaterialCombine[10000])
//}
//var counter = 0
//for material in allMaterialCombine {
//    let si = Simulation()
//    let rgbStatus = await si.Simulate(MaterialCombination: material)
//    let (statusR, statusG, statusB) = (rgbStatus.statusR, rgbStatus.statusG, rgbStatus.statusB)
//    counter += 1
//    print(counter, "/", allMaterialCombine.count, ":", statusR[6].1 * 255, statusG[6].1 * 255, statusB[6].1 * 255)
//}


var obj = await LoadModel(path: "/Users/thomasb/Downloads/cube.stl")
var mesh = extractSingleMesh(from: obj!)

var model = [Tri]()

if isMeshWatertight(mesh!) {
    model = extractTriangles(from: mesh!)
    print(model)
} else {
    print("Not a closed mesh!")
    Darwin.exit(1)
}


