//
//  Plane.swift
//  macOS
//
//  Created by Kota Nakano on 2017/09/12.
//
//

import simd
struct Plane {
	let center: float3
	let normal: float3
}
extension Plane: ObjectInterface {
	var object: Object {
		let flags: uint4 = uint4(1, 0, 0, 0)
		let attributes: float3x4 = float3x4([float4(center.x, center.y, center.z, 1),
		                                     float4(normal.x, center.y, center.z, 0), float4(0)])
		return Object(flags: flags, attributes: attributes)
	}
}
