//
//  Sphere.swift
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//
import simd
struct Sphere {
	let center: float3
	let radius: Float
}
extension Sphere: ObjectInterface {
	var object: Object {
		return Object(flags: uint4(0, 0, 0, 0),
		              attributes: (float4(center.x, center.y, center.z, radius), float4(0), float4(0)),
		              options: (float4x4(0), float4x4(0), float4x4(0)))
	}
}
