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
		let flags: uint4 = uint4(0)
		let attributes: float3x4 = float3x4([float4(arrayLiteral: center.x, center.y, center.z, radius), float4(0), float4(0)])
		return Object(flags: flags, attributes: attributes)
	}
}
