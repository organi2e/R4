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
		return Object(flags: uint4(1, 0, 0, 0),
		              attributes: (float4(center.x, center.y, center.z, 1),
		                           float4(normal.x, normal.y, normal.z, 0),
		                           float4(0)),
		              options: (float4x4(0),
		                        float4x4(0),
		                        float4x4(0)))
	}
}
