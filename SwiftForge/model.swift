//
//  model.swift
//  SwiftForge
//
//  Created by Thomas B on 1/22/26.
//

import ModelIO
import Foundation
import simd

struct Tri {
    var i0: SIMD3<f64>
    var i1: SIMD3<f64>
    var i2: SIMD3<f64>
    var normal: SIMD3<f64>

    init(i0: SIMD3<f64>, i1: SIMD3<f64>, i2: SIMD3<f64>, normal: SIMD3<f64> = .zero) {
        self.i0 = i0
        self.i1 = i1
        self.i2 = i2
        self.normal = normal
    }
}

// Models/cube.stl
func LoadModel(path: String) async -> MDLObject? {
    let url = URL(fileURLWithPath: path)
    let asset = MDLAsset(url: url)
    var first: MDLObject?
    asset.childObjects(of: MDLObject.self).forEach { obj in
        if first == nil { first = obj }
    }
    return first
}

func extractSingleMesh(from object: MDLObject) -> MDLMesh? {

    // must be a mesh itself
    guard let mesh = object as? MDLMesh else {
        return nil
    }

    // must not contain other meshes
    if object.children.count != 0 {
        return nil
    }

    return mesh
}

// MARK: - Triangle Extraction
// Loads all triangles from an MDLMesh and returns them as [Tri]
func extractTriangles(from mesh: MDLMesh) -> [Tri] {

    var result: [Tri] = []

    // ---- read vertex positions ----
    guard let attr = mesh.vertexAttributeData(
        forAttributeNamed: MDLVertexAttributePosition,
        as: .float3
    ) else {
        return []
    }

    let vertexStride = attr.stride
    let base = attr.dataStart

    func position(_ i: Int) -> SIMD3<Double> {
        let p = base
            .advanced(by: i * vertexStride)
            .assumingMemoryBound(to: SIMD3<Float>.self)
        let v = p.pointee
        return SIMD3(Double(v.x), Double(v.y), Double(v.z))
    }

    // ---- indexed mesh ----
    if let subs = mesh.submeshes as? [MDLSubmesh], !subs.isEmpty {

        for sm in subs where sm.geometryType == .triangles {
            let raw = sm.indexBuffer.map().bytes
            let n = sm.indexCount

            if sm.indexType == .uInt16 {
                let p = raw.bindMemory(to: UInt16.self, capacity: n)
                for i in stride(from: 0, to: n, by: 3) {
                    let a = Int(p[i])
                    let b = Int(p[i + 1])
                    let c = Int(p[i + 2])
                    result.append(Tri(
                        i0: position(a),
                        i1: position(b),
                        i2: position(c)
                    ))
                }
            }

            if sm.indexType == .uInt32 {
                let p = raw.bindMemory(to: UInt32.self, capacity: n)
                for i in stride(from: 0, to: n, by: 3) {
                    let a = Int(p[i])
                    let b = Int(p[i + 1])
                    let c = Int(p[i + 2])
                    result.append(Tri(
                        i0: position(a),
                        i1: position(b),
                        i2: position(c)
                    ))
                }
            }
        }

    } else {
        // ---- STL-style triangle soup ----
        let v = mesh.vertexCount
        for i in stride(from: 0, to: v - 2, by: 3) {
            result.append(Tri(
                i0: position(i),
                i1: position(i + 1),
                i2: position(i + 2)
            ))
        }
    }

    return result
}

//MARK: -Model Watertight Test
func isMeshWatertight(_ mesh: MDLMesh, epsilon: Double = 1e-9) -> Bool {

    struct VKey: Hashable {
        let x: Int64
        let y: Int64
        let z: Int64
    }

    struct Edge: Hashable {
        let a: Int
        let b: Int
        init(_ i: Int, _ j: Int) {
            if i < j { a = i; b = j }
            else { a = j; b = i }
        }
    }

    // ---- read vertex positions ----
    // Note: Some SDKs do not expose `MDLVertexFormat.double3`, so we read as float3 and convert.
    guard let attr = mesh.vertexAttributeData(
        forAttributeNamed: MDLVertexAttributePosition,
        as: .float3
    ) else { return false }

    let vertexStride = attr.stride
    let base = attr.dataStart

    func position(_ i: Int) -> SIMD3<Double> {
        let p = base.advanced(by: i * vertexStride)
            .assumingMemoryBound(to: SIMD3<Float>.self)
        let v = p.pointee
        return SIMD3(Double(v.x), Double(v.y), Double(v.z))
    }

    // ---- vertex deduplication (STL safe) ----
    var vertexMap: [VKey: Int] = [:]
    var nextID = 0

    func vid(_ i: Int) -> Int {
        let p = position(i)
        let k = VKey(
            x: Int64(p.x / epsilon),
            y: Int64(p.y / epsilon),
            z: Int64(p.z / epsilon)
        )
        if let id = vertexMap[k] { return id }
        vertexMap[k] = nextID
        nextID += 1
        return nextID - 1
    }

    // ---- collect triangles ----
    var triangles: [(Int, Int, Int)] = []

    if let subs = mesh.submeshes as? [MDLSubmesh], !subs.isEmpty {

        for sm in subs where sm.geometryType == .triangles {
            let raw = sm.indexBuffer.map().bytes
            let n = sm.indexCount

            if sm.indexType == .uInt16 {
                let p = raw.bindMemory(to: UInt16.self, capacity: n)
                for i in stride(from: 0, to: n, by: 3) {
                    triangles.append((Int(p[i]), Int(p[i+1]), Int(p[i+2])))
                }
            }

            if sm.indexType == .uInt32 {
                let p = raw.bindMemory(to: UInt32.self, capacity: n)
                for i in stride(from: 0, to: n, by: 3) {
                    triangles.append((Int(p[i]), Int(p[i+1]), Int(p[i+2])))
                }
            }
        }

    } else {
        // STL-style triangle soup
        let v = mesh.vertexCount
        for i in stride(from: 0, to: v - 2, by: 3) {
            triangles.append((i, i + 1, i + 2))
        }
    }

    if triangles.isEmpty { return false }

    // ---- edge counting ----
    var edges: [Edge: Int] = [:]

    for (a, b, c) in triangles {
        let i0 = vid(a)
        let i1 = vid(b)
        let i2 = vid(c)

        edges[Edge(i0, i1), default: 0] += 1
        edges[Edge(i1, i2), default: 0] += 1
        edges[Edge(i2, i0), default: 0] += 1
    }

    // ---- watertight rule ----
    for (_, count) in edges {
        if count != 2 { return false }
    }

    return true
}
